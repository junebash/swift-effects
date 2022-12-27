import Effects

actor TestSend<Value>: Receiver {
  var values: [Value] = []

  func send(_ value: Value) {
    values.append(value)
  }
}
