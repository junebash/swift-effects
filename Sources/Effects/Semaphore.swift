import DequeModule

public actor Semaphore {
  private struct Suspension: Equatable {
    var id: UUID
  }
  private var continuations: Deque<CheckedContinuation<Void, Never>> = []

  public var value: Int

  public init(value: Int = 0) {
    self.value = value
  }

  deinit {
    for continuation in continuations {
      continuation.resume()
    }
  }

  public func wait() async {
    value -= 1
    if value >= 0 {
      return
    }

    await withTaskCancellationHandler {

    } onCancel: {
      <#code#>
    }
  }

  public func open() {
    isOpen = true
    if continuations.isEmpty { return }
    
    let continuations = self.continuations
    self.continuations.removeAll(keepingCapacity: true)
    for continuation in continuations {
      continuation.resume()
    }
  }

  public func close() {
    isOpen = false
  }
}
