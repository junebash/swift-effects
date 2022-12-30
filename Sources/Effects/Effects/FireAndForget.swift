public struct FireAndForget<Value>: Effect {
  public let operation: @Sendable () async -> Void

  public init(_ operation: @escaping @Sendable () async -> Void) {
    self.operation = operation
  }

  public init(
    _ operation: @escaping @Sendable () async throws -> Void,
    catch handleError: @escaping @Sendable (Error) async -> Void
  ) {
    self.operation = {
      do {
        try await operation()
      } catch {
        await handleError(error)
      }
    }
  }

  public func run(_ send: some Receiver<Value>) async {
    await operation()
  }
}
