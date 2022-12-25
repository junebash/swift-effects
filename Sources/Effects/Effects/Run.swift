public struct Run<Value>: Effect {
  public let priority: TaskPriority?
  public let operation: @Sendable (any Receiver<Value>) async -> Void

  public init(
    priority: TaskPriority? = nil,
    run: @escaping @Sendable (any Receiver<Value>) async -> Void
  ) {
    self.priority = priority
    self.operation = run
  }

  public init(
    priority: TaskPriority? = nil,
    run: @escaping @Sendable (any Receiver<Value>) async throws -> Void,
    catch handleError: @escaping @Sendable (Error, any Receiver<Value>) async -> Void
  ) {
    self.init(priority: priority) { send in
      do {
        try await run(send)
      } catch is CancellationError {
        return
      } catch {
        await handleError(error, send)
      }
    }
  }

  public func run(_ send: some Receiver<Value>) async {
    await Task(priority: priority) {
      await operation(send)
    }.cancellableValue
  }
  }
