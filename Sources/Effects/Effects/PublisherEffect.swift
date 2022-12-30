#if canImport(Combine)
@preconcurrency import Combine

public struct PublisherEffect<P: Publisher>: Effect where P.Failure == Never {
  public typealias Value = P.Output

  public let publisher: @Sendable () -> P

  public init(_ publisher: @escaping @Sendable () -> P) {
    self.publisher = publisher
  }

  public func run(_ send: some Receiver<Value>) async {
    for await value in makeStream() {
      guard !Task.isCancelled else { return }
      await send(value)
      guard !Task.isCancelled else { return }
    }
  }

  private func makeStream() -> AsyncStream<P.Output> {
    AsyncStream { continuation in
      let cancellable = publisher().sink(
        receiveCompletion: { _ in continuation.finish() },
        receiveValue: { continuation.yield($0) }
      )
      continuation.onTermination = { _ in
        cancellable.cancel()
      }
    }
  }
}

extension Publisher where Failure == Never, Self: Sendable {
  public var effect: PublisherEffect<Self> {
    .init({ self })
  }
}
#endif
