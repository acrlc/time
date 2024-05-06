import Foundation // For the side effect of reexporting Darwin/Glibc
import struct Foundation.Date
import struct Foundation.TimeInterval

@available(macOS 13.0, *)
/// A clock for events that rely on date
public struct DateClock: Clock {
 @inline(__always)
 public var now: Date { .now }
 public var minimumResolution: Date.TimeInterval = 1e-9
 private let clock = ContinuousClock()
}

@available(macOS 13.0, *)
public extension DateClock {
 func sleep(until deadline: Date, tolerance: TimeInterval? = nil) async throws {
  let duration: Swift.Duration =
   .seconds(deadline.timeIntervalSince(now))
  try await clock.sleep(
   until: .now.advanced(by: duration),
   tolerance: .seconds(tolerance ?? minimumResolution)
  )
 }

 func sleep(tolerance: TimeInterval? = nil) async throws {
  try await clock.sleep(
   until: .now.advanced(by: Swift.Duration.seconds(now.timeIntervalSinceNow)),
   tolerance: .seconds(tolerance ?? minimumResolution)
  )
 }
}

@available(macOS 13.0, *)
public extension Clock where Self == DateClock {
 static var date: Self { Self() }
}

@available(macOS 13.0, *)
extension TimeInterval: DurationProtocol {
 public static func * (lhs: Double, rhs: Int) -> Double {
  lhs * Double(rhs)
 }

 public static func / (lhs: Double, rhs: Int) -> Double {
  lhs / Double(rhs)
 }

 public var duration: Duration { .seconds(self) }
}

@available(macOS 13.0, *)
extension Date: InstantProtocol {
 public func duration(to other: Self) -> TimeInterval {
  timeIntervalSince(other)
 }
}

// MARK: - Tick Implementation
@available(macOS 13.0, *)
/// A clock for events that rely on relative time
public struct TimeClock: Clock {
 @inline(__always)
 public var now: Tick { .now }
 public var minimumResolution: Time = .nanosecond
 private let clock = ContinuousClock()
}

@available(macOS 13.0, *)
public extension TimeClock {
 func sleep(until deadline: Tick, tolerance: Time? = nil) async throws {
  let duration: Swift.Duration = deadline.elapsedTime(since: now).duration
  try await clock.sleep(
   until: .now.advanced(by: duration),
   tolerance: .seconds((tolerance ?? minimumResolution).rawValue)
  )
 }

 func sleep(tolerance: Time? = nil) async throws {
  try await clock.sleep(
   until: .now.advanced(
    by: Swift.Duration.seconds(now.timeIntervalSinceNow.rawValue)
   ),
   tolerance: .seconds((tolerance ?? minimumResolution).rawValue)
  )
 }
}

@available(macOS 13.0, *)
public extension Clock where Self == TimeClock {
 static var time: Self { Self() }
}

@available(macOS 13.0, *)
extension Time: DurationProtocol, AdditiveArithmetic {
 public static func + (lhs: Time, rhs: Time) -> Time {
  Time(lhs.rawValue + rhs.rawValue)
 }

 public static func - (lhs: Time, rhs: Time) -> Time {
  Time(lhs.rawValue - rhs.rawValue)
 }

 public static func / (lhs: Time, rhs: Time) -> Time {
  Time(lhs.rawValue / rhs.rawValue)
 }

 public static func * (lhs: Time, rhs: Int) -> Time {
  Time(lhs.rawValue * Double(rhs))
 }

 public static func / (lhs: Time, rhs: Int) -> Time {
  Time(lhs.rawValue / Double(rhs))
 }

 public static func / (lhs: Time, rhs: Time) -> Double {
  lhs.rawValue / rhs.rawValue
 }

 public var duration: Duration { .seconds(rawValue) }
}

@available(macOS 13.0, *)
extension Tick: InstantProtocol, Hashable {
 #if !USE_FOUNDATION_DATE && (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
 public func advanced(by duration: Time) -> Tick {
  let start = Tick(
   _value: .init(duration.duration)
  )
  let s = _value.tv_sec + start._value.tv_sec
  let ns = _value.tv_nsec + start._value.tv_nsec
  return Tick(_value: timespec(tv_sec: s, tv_nsec: ns))
 }

 public static func < (lhs: Tick, rhs: Tick) -> Bool {
  lhs._value.tv_sec <= rhs._value.tv_sec &&
   lhs._value.tv_nsec <= rhs._value.tv_nsec
 }

 public func duration(to other: Self) -> Time {
  let s = Double(other._value.tv_sec - _value.tv_sec)
  let ns = Double(other._value.tv_nsec - _value.tv_nsec)
  return Time(s + ns / 1e9)
 }
 #else
 public func advanced(by duration: Time) -> Tick {
  Tick(_value: _value.advanced(by: duration.rawValue))
 }

 public static func < (lhs: Tick, rhs: Tick) -> Bool {
  lhs._value < rhs._value
 }

 public func duration(to other: Self) -> Time {
  Time(_value.timeIntervalSince(other._value))
 }
 #endif

 public func hash(into hasher: inout Hasher) {
  hasher.combine(_value)
 }
}

#if !USE_FOUNDATION_DATE && (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
extension timespec: Hashable {
 public static func == (lhs: timespec, rhs: timespec) -> Bool {
  lhs.tv_sec == rhs.tv_sec &&
   lhs.tv_nsec == rhs.tv_nsec
 }

 public func hash(into hasher: inout Hasher) {
  hasher.combine(tv_sec)
  hasher.combine(tv_nsec)
 }
}
#endif
