@testable import Time
import XCTest

final class TimeTests: XCTestCase {
 var timer: some TimerProtocol = .standard

 override func setUp() {
  print("Resetting timer ...")
  timer.reset()
 }

 func testTimer() async throws {
  let times: [UInt32] = [1, 2]

  for int in times {
   XCTAssertEqual(timer.fireDate, .distantFuture)

   timer.fire() // records the time when started
   try await Task.sleep(for: .seconds(int))

   // read elapsed time
   let time = timer.elapsed
   let projectedTime = try XCTUnwrap(Time("\(int)s"))

   XCTAssertEqual(time, projectedTime, accuracy: 0.1)

   timer.invalidate() // invalidates the timer, if needed
   XCTAssertEqual(timer.fireDate, .distantPast)

   timer.reset() // resets the timer, when needed to skip measurements
   XCTAssertEqual(timer.fireDate, .distantFuture)
  }

  dump(timer)
  XCTAssertEqual(timer.elapsed, .nanosecond)
 }

 func testSize() async throws {
  let size: Size = 3
  let times: [UInt32] = (0 ..< 3).map { _ in 333_333 }

  timer.fire()

  // iterate 3 times, sleep for 333333µs three times
  for _ in size {
   for int in times {
    try await Task.sleep(for: .microseconds(int))
   }
  }

  let time = timer.elapsed
  let projectedTime = try XCTUnwrap(Time("3s"))

  XCTAssertEqual(time, projectedTime, accuracy: 0.2)

  let average = time.amortized(over: size)
  XCTAssertEqual(average, 1, accuracy: 0.1)
  dump(average)
 }
}
