import DequeModule
import Lock
import UUID

public actor Signaller {
  private typealias Continuation = AsyncStream<Never>.Continuation

  private struct Suspension {
    let id: UUID
    let continuation: Continuation
  }

  private var suspensions: Deque<Suspension> = []

  public init() {}

  deinit {
    while let suspension = suspensions.popFirst() {
      suspension.continuation.finish()
    }
  }

  public func wait() async {
    let id = UUID()
    let stream = AsyncStream(Never.self) { continuation in
      suspensions.append(Suspension(id: id, continuation: continuation))
      continuation.onTermination = { _ in
        Task(priority: .high) { await self.cancel(id: id) }
      }
    }

    await Task.detached {
      for await _ in stream {}
    }.cancellableValue
  }

  public func signal(_ value: Int = 1) {
    guard value > 0 else { return }
    let subset = self.suspensions.prefix(value)
    for suspension in subset {
      suspension.continuation.finish()
    }
    if value > suspensions.count {
      self.suspensions.removeAll()
    } else {
      self.suspensions.removeFirst(value)
    }
  }

  private func cancel(id: UUID) {
    suspensions.removeAll(where: { $0.id == id })
  }
}

extension Signaller {
  @available(macOS 13, *)
  @available(iOS 16, *)
  @available(tvOS 16, *)
  @available(watchOS 9, *)
  public nonisolated func wait<C: Clock>(_ value: Int, timeout: C.Duration, clock: C) async -> Bool {
    let waitTask = Task.detached {
      await self.wait()
      return !Task.isCancelled
    }
    let timeoutTask = Task.detached {
      try await clock.sleep(until: clock.now.advanced(by: timeout), tolerance: nil)
      waitTask.cancel()
    }
    return await withTaskCancellationHandler {
      await waitTask.value
    } onCancel: {
      waitTask.cancel()
      timeoutTask.cancel()
    }
  }
}
