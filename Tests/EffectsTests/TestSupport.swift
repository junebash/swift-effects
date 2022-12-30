import Effects

actor TestSend<Value: Sendable>: Receiver {
  var values: [Value] = []

  func send(_ value: Value) {
    values.append(value)
  }
}
