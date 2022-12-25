public struct Empty<Value>: Effect {
  public init() {}

  public func run(_ send: some Receiver<Value>) {}
}

extension Empty: Hashable {}
