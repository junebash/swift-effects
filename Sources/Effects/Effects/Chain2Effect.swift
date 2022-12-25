extension Effect {
  public func chaining<Other: Effect<Value>>(_ other: Other) -> Chain2Effect<Self, Other> {
    .init(first: self, second: other)
  }
}

public struct Chain2Effect<First: Effect, Second: Effect>: Effect
where First.Value == Second.Value {
  public typealias Value = First.Value

  public let first: First
  public let second: Second

  public init(first: First, second: Second) {
    self.first = first
    self.second = second
  }

  public func run(_ send: some Receiver<Value>) async {
    await first.run(send)
    guard !Task.isCancelled else { return }
    await second.run(send)
  }
}
