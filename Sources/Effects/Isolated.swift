public actor ActorIsolated<Value> {
  public var value: Value

  public init(_ initialValue: Value) {
    self.value = initialValue
  }

  public func withValue<Output>(_ perform: (inout Value) throws -> Output) rethrows -> Output {
    try perform(&value)
  }
}

public struct LockIsolated<Value>: Sendable {
  private var state: ManagedCriticalState<Value>

  public init(_ initialValue: Value) {
    self.state = ManagedCriticalState(initialValue)
  }

  public func withValue<Output>(_ perform: (inout Value) throws -> Output) rethrows -> Output {
    try state.withCriticalRegion { value in
      try perform(&value)
    }
  }
}
extension LockIsolated: Equatable where Value: Equatable {
  public static func == (lhs: LockIsolated<Value>, rhs: LockIsolated<Value>) -> Bool {
    lhs.withValue { l in
      rhs.withValue { r in
        l == r
      }
    }
  }
}

public struct UncheckedSendable<Value>: @unchecked Sendable {
  public var value: Value

  public init(_ value: Value) {
    self.value = value
  }
}
