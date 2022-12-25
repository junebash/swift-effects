extension Effect {
  public func cancellable<ID>(
    id: ID.Type,
    cancelInFlight: Bool = false
  ) -> CancellableEffect<Self> {
    .init(base: self, id: ObjectIdentifier(id), cancelInFlight: cancelInFlight)
  }

  public func cancellable(
    id: some Hashable & Sendable,
    cancelInFlight: Bool = false
  ) -> CancellableEffect<Self> {
    .init(base: self, id: id, cancelInFlight: cancelInFlight)
  }
}

public struct CancellableEffect<Base: Effect>: Effect {
  public typealias Value = Base.Value

  public let base: Base
  public let id: any Hashable & Sendable
  public let cancelInFlight: Bool

  @inlinable
  internal init(base: Base, id: any Hashable & Sendable, cancelInFlight: Bool) {
    self.base = base
    self.id = id
    self.cancelInFlight = cancelInFlight
  }

  @inlinable
  public func run(_ send: some Receiver<Base.Value>) async {
    let task = Task {
      await base.run(send)
    }
    await EffectCancellables.current.enqueueTask(
      task,
      forID: id,
      cancelInFlight: cancelInFlight
    )
    await task.cancellableValue
  }
}
