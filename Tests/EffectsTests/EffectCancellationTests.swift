import XCTest
import Effects

final class EffectCancellationTests: XCTestCase {
  struct LongRunningEffect: Effect {
    typealias Value = Int

    func run(_ send: some Receiver<Int>) async {
      do {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1_000_000)
        await send(666)
      } catch {
        await send(42)
      }
    }
  }

  func testBasics() async {
    enum CancelID {}

    let effect = LongRunningEffect()
      .cancellable(id: CancelID.self)
    let send = TestSend<Int>()
    let semaphore = Signaller()

    let effectTask = Task.detached {
      await semaphore.signal()
      await effect.run(send)
    }
    await semaphore.wait()

    let cancelEffect = CancelEffect<Int>(id: CancelID.self)
    await cancelEffect.run(send)
    await effectTask.value

    let state = await send.values
    XCTAssertEqual(state, [42])
  }
}
