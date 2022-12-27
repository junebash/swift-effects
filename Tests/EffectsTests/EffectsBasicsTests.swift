import XCTest
import Effects

final class swift_effectsTests: XCTestCase {
    func testBasics() async {
      struct BasicEffect: Effect {
        typealias Value = Int

        func run(_ send: some Receiver<Int>) async {
          await send(42)
        }
      }

      actor BasicReceiver: Receiver {
        var count = 0

        func send(_ value: Int) {
          count += value
        }
      }

      let effect = BasicEffect()
      let send = BasicReceiver()

      await effect.run(send)
      var count = await send.count
      XCTAssertEqual(count, 42)

      await effect.run(send)
      count = await send.count
      XCTAssertEqual(count, 84)
    }
}
