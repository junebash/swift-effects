public protocol Receiver<Value>: Sendable {
  associatedtype Value

  func send(_ value: Value) async
}

extension Receiver {
  @inlinable
  public func callAsFunction(_ value: Value) async {
    await send(value)
  }
}
