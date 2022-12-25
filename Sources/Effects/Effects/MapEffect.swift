extension Effect {
  public func map<NewValue>(
    _ transform: @escaping @Sendable (Value) async -> NewValue
  ) -> MapEffect<Self, NewValue> {
    MapEffect(base: self, transform: transform)
  }
}

public struct MapEffect<Base: Effect, Value>: Effect {
  public let base: Base
  public let transform: @Sendable (Base.Value) async -> Value

  public init(base: Base, transform: @escaping @Sendable (Base.Value) async -> Value) {
    self.base = base
    self.transform = transform
  }

  @inlinable
  public func run(_ send: some Receiver<Value>) async {
    await base.run(Scope(child: send, transform: transform))
  }
}
