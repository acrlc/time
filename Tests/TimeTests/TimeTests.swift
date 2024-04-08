@testable import Time
import XCTest

final class TimeTests: XCTestCase {
 func testTimer() async throws {
  let times: [UInt32] = [1, 2]
  var timer: TimerProtocol = .standard

  for int in times {
   XCTAssertEqual(timer.fireDate, .distantFuture)

   timer.fire() // records the time when started
   try await Task.sleep(for: .seconds(int))

   // read elapsed time
   let elapsed = timer.elapsed
   let time = Time(elapsed.seconds.rounded(.down))
   let projectedTime = try XCTUnwrap(Time("\(int)s"))

   XCTAssertEqual(time.description, projectedTime.description)

   timer.invalidate() // invalidates the timer, if needed
   XCTAssertEqual(timer.fireDate, .distantPast)

   timer.reset() // resets the timer, when needed to skip measurements
   XCTAssertEqual(timer.fireDate, .distantFuture)
  }
 }

 func testSize() async throws {
  let size: Size = 3
  let times: [UInt32] = (0 ..< 3).map { _ in 333_333 }
  var timer: TimerProtocol = .standard

  timer.fire()

  // iterate 3 times, sleep for 333333µs three times
  for _ in size {
   for int in times {
    try await Task.sleep(for: .milliseconds(int / 1000))
   }
  }

  let elapsed = timer.elapsed
  let time = Time(elapsed.seconds.rounded(.down))
  let projectedTime = try XCTUnwrap(Time("3s"))

  XCTAssertEqual(time.description, projectedTime.description)

  let average = elapsed.amortized(over: size)
  let averageRounded = Time(average.seconds.rounded(.down))

  XCTAssertEqual(averageRounded, Time(1))
 }
}
