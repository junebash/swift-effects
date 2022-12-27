public struct Send<Value>: Receiver {
  private let _send: @Sendable (Value) async -> Void

  public init(_ send: @escaping @Sendable (Value) async -> Void) {
    self._send = send
  }

  public func send(_ value: Value) async {
    await _send(value)
  }
}
