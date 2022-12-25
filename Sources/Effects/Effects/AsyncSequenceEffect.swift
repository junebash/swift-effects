extension AsyncSequence {
  public func effect(
    catch handleError: (@Sendable (Error, any Receiver<Element>) async -> Void)?
  ) -> AsyncSequenceEffect<Self> {
    .init(sequence: self, handleError: handleError)
  }

  public func effect(
    catch handleError: (@Sendable (Error) async -> Element?)? = nil
  ) -> AsyncSequenceEffect<Self> {
    if let handleError {
      return .init(sequence: self, handleError: { error, send in
        if let value = await handleError(error) {
          await send(value)
        }
      })
    } else {
      return .init(sequence: self, handleError: nil)
    }
  }
}

public struct AsyncSequenceEffect<S: AsyncSequence & Sendable>: Effect {
  public typealias Value = S.Element

  public let sequence: S
  public let handleError: (@Sendable (Error, any Receiver<S.Element>) async -> Void)?

  public func run(_ send: some Receiver<S.Element>) async {
    do {
      for try await value in sequence {
        try Task.checkCancellation()
        await send(value)
        try Task.checkCancellation()
      }
    } catch is CancellationError {
      return
    } catch {
      guard let handleError else {
        return assertionFailure("AsyncSequence \(S.self) threw uncaught error: \(error)")
      }
      await handleError(error, send)
    }
  }
}
