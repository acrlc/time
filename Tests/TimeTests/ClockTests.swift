@testable import Time
import XCTest

final class ClockTests: XCTestCase {
 func testClock() async throws {
  let tickClock = ContinuousTickClock()
  try await tickClock.sleep(until: .now.advanced(by: .init(5)))
  print("Hello")
 }
}
