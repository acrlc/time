import struct Foundation.Date
import struct Foundation.TimeInterval

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
/// A clock for events that rely on date
public struct DateClock: Clock {
 @inline(__always)
 public var now: Date { .now }
 public var minimumResolution: TimeInterval = 1e-9
 public init() {}
 public init(minimumResolution: TimeInterval) {
  self.minimumResolution = minimumResolution
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension DateClock {
 func sleep(until deadline: Date, tolerance: TimeInterval? = nil) async throws {
  try await Task.sleep(
   until: .now.advanced(by: .seconds(now.duration(to: deadline))),
   tolerance: .seconds(tolerance ?? minimumResolution), clock: .continuous
  )
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension Clock where Self == DateClock {
 static var date: Self { Self() }
 static func date(minimumResolution: TimeInterval) -> Self {
  Self(minimumResolution: minimumResolution)
 }
}

extension TimeInterval: DurationProtocol {
 public static func * (lhs: Double, rhs: Int) -> Double {
  lhs * Double(rhs)
 }

 public static func / (lhs: Double, rhs: Int) -> Double {
  lhs / Double(rhs)
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension TimeInterval {
 @inline(__always)
 var duration: Duration { .seconds(self) }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Date: InstantProtocol {
 public func duration(to other: Self) -> TimeInterval {
  Double(other.timeIntervalSince(self))
 }
}

// MARK: - Tick Implementation
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
/// A clock for events that rely on relative time
public struct TimeClock: Clock {
 @inline(__always)
 public var now: Tick { .now }
 public var minimumResolution: Time = Tick.resolution
 public init() {}
 public init(minimumResolution: Time) {
  self.minimumResolution = minimumResolution
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension TimeClock {
 func sleep(until deadline: Tick, tolerance: Time? = nil) async throws {
  try await Task.sleep(
   until: .now.advanced(by: .seconds(now.duration(to: deadline).rawValue)),
   tolerance: .seconds((tolerance ?? minimumResolution).rawValue),
   clock: .continuous
  )
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension Clock where Self == TimeClock {
 static var time: Self { Self() }
 static func date(minimumResolution: Time) -> Self {
  Self(minimumResolution: minimumResolution)
 }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Time: DurationProtocol {
 @inline(__always)
 public var duration: Duration { .seconds(rawValue) }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Tick: InstantProtocol {}
