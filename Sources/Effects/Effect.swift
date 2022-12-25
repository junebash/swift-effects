public protocol Effect<Value>: Sendable {
    associatedtype Value

    func run(_ send: some Receiver<Value>) async
}
