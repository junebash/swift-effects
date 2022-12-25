extension Effect {
  @inlinable
  public static func cancel<Value, ID>(id: ID.Type) -> Self
  where Self == CancelEffect<Value> {
    .init(id: ObjectIdentifier(id))
  }

  @inlinable
  public static func cancel<Value>(id: some Hashable & Sendable) -> Self
  where Self == CancelEffect<Value> {
    .init(id: id)
  }

  @inlinable
  public func cancel<ID>(id: ID.Type) -> Chain2Effect<Self, CancelEffect<Value>> {
    self.chaining(CancelEffect(id: id))
  }

  @inlinable
  public func cancel(id: some Hashable & Sendable) -> Chain2Effect<Self, CancelEffect<Value>> {
    self.chaining(CancelEffect(id: id))
  }
}

public struct CancelEffect<Value>: Effect {
  public let id: any Hashable & Sendable

  public init(id: some Hashable & Sendable) {
    self.id = id
  }

  public init<ID>(id: ID.Type) {
    self.id = ObjectIdentifier(id)
  }

  public func run(_ send: some Receiver<Value>) async {
    await EffectCancellables.current.cancelTask(forID: id)
  }
}
