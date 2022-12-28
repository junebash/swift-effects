public actor ActorIsolated<Value> {
  public var value: Value

  public init(_ initialValue: Value) {
    self.value = initialValue
  }

  public func withValue<Output>(_ perform: (inout Value) throws -> Output) rethrows -> Output {
    try perform(&value)
  }
}

public struct UncheckedSendable<Value>: @unchecked Sendable {
  public var value: Value

  public init(_ value: Value) {
    self.value = value
  }
}
