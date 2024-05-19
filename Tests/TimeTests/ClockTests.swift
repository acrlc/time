@testable import Time
import XCTest

final class ClockTests: XCTestCase {
 var timer: some TimerProtocol = .standard

 override func setUp() {
  print("Starting timer ...")
  timer.fire()
 }

 func testDateClock() async throws {
  let clock = DateClock()
  
  try await clock.sleep(until: .now + 0.75)
  let time = timer.elapsed

  XCTAssertEqual(time, 0.75, accuracy: 0.01)
  dump(clock)
  print(time)
 }

 func testTimeClock() async throws {
  let clock = TimeClock()
  
  try await clock.sleep(until: .now + 1.25)
  let time = timer.elapsed
  
  XCTAssertEqual(time, 1.25, accuracy: 0.01)
  dump(clock)
  print(time)
 }
}
