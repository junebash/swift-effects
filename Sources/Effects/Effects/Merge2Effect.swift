extension Effect {
  public func merged<Other: Effect<Value>>(with other: Other) -> Merge2Effect<Self, Other> {
    .init(first: self, second: other)
  }
}

public struct Merge2Effect<First: Effect, Second: Effect>: Effect where First.Value == Second.Value {
  public typealias Value = First.Value

  public let first: First
  public let second: Second

  public init(first: First, second: Second) {
    self.first = first
    self.second = second
  }

  public func run(_ send: some Receiver<Value>) async {
    async let a: Void = first.run(send)
    async let b: Void = second.run(send)
    _ = await (a, b)
  }
}
