public struct DeferredTask<Value>: Effect {
  public let priority: TaskPriority?
  public let operation: @Sendable () async -> Value?

  public init(
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async -> Value?
  ) {
    self.priority = priority
    self.operation = operation
  }

  public init(
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async throws -> Value?,
    catch handleError: @escaping @Sendable (Error) async -> Value?
  ) {
    self.init(priority: priority) {
      do {
        return try await operation()
      } catch is CancellationError {
        return nil
      } catch {
        return await handleError(error)
      }
    }
  }

  public func run(_ send: some Receiver<Value>) async {
    await Task(priority: priority) {
      guard let value = await operation() else { return }
      await send(value)
    }.cancellableValue
  }
}
