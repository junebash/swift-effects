public actor EffectCancellables {
  @usableFromInline
  internal var tasks: [AnyHashable: AutoCancel] = [:]

  public init() {}

  @inlinable
  public init(rebasingFrom other: EffectCancellables) async {
    self.tasks = await other.tasks
  }

  @TaskLocal public static var current: EffectCancellables = .init()

  @inlinable
  public func enqueueTask<ID>(_ task: Task<Void, Never>, forID id: ID.Type, cancelInFlight: Bool) {
    enqueueTask(task, forID: ObjectIdentifier(id), cancelInFlight: cancelInFlight)
  }

  @inlinable
  public func enqueueTask(_ task: Task<Void, Never>, forID key: some Hashable & Sendable, cancelInFlight: Bool) {
    if cancelInFlight, let existingTask = tasks.removeValue(forKey: key) {
      existingTask.cancel()
    }
    tasks[key] = AutoCancel(task)
  }

  @inlinable
  public func cancelTask<ID>(forID: ID.Type) {
    cancelTask(forID: ObjectIdentifier(ID.self))
  }

  @inlinable
  public func cancelTask(forID key: some Hashable & Sendable) {
    guard let task = tasks.removeValue(forKey: key) else { return }
    task.cancel()
  }
}
