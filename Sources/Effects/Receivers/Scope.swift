public struct Scope<Child: Receiver, Value>: Receiver {
  public let child: Child
  public let transform: @Sendable (Value) async -> Child.Value

  @inlinable
  public init(child: Child, transform: @escaping @Sendable (Value) async -> Child.Value) {
    self.child = child
    self.transform = transform
  }

  @inlinable
  public func send(_ value: Value) async {
    await child(transform(value))
  }
}
