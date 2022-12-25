public protocol Cancellable {
  func cancel()
}

public final class AutoCancel: Cancellable {
  private let _cancel: @Sendable () -> Void

  public init(cancel: @escaping @Sendable () -> Void) {
    _cancel = cancel
  }

  public init(_ cancellable: some Cancellable) {
    self._cancel = { cancellable.cancel() }
  }

  public func cancel() {
    _cancel()
  }
}

extension Task: Cancellable {}
