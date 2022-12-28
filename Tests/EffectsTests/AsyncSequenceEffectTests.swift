import XCTest
import Effects

final class AsyncSequenceEffectTests: XCTestCase {
  func testBasics() async {
    let stream = AsyncStream<Int> { continuation in
      let task = Task.detached {
        await Task.yield()
        continuation.yield(42)
        await Task.yield()
        continuation.yield(69)
        await Task.yield()
        continuation.finish()
      }
      continuation.onTermination = { _ in
        task.cancel()
      }
    }

    let effect = stream.effect()
    let send = TestSend<Int>()

    await effect.run(send)

    let state = await send.values
    XCTAssertEqual(state, [42, 69])
  }

  func testCancellation() async {
    let stream = AsyncStream<Int> { continuation in
      let task = Task {
        continuation.yield(42)
        do {
          try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1_000_000)
        } catch {
          continuation.yield(777)
          continuation.finish()
          return
        }
        continuation.yield(666)
      }
      continuation.onTermination = { _ in
        task.cancel()
      }
    }

    let effect = stream.effect()
    let send = TestSend<Int>()
    let semaphore = Signaller()

    let effectTask = Task {
      await semaphore.signal()
      await effect.run(send)
    }

    await semaphore.wait()
    effectTask.cancel()
    await effectTask.value

    let state = await send.values
    XCTAssertEqual(state, [42])
  }
}
