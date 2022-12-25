public struct Just<Value>: Effect {
  public let value: @Sendable () -> Value

  public init(_ value: @escaping @Sendable () -> Value) {
    self.value = value
  }

  public init(_ value: @escaping @autoclosure @Sendable () -> Value) {
    self.value = value
  }

  public func run(_ send: some Receiver<Value>) async {
    await send(value())
  }
}
