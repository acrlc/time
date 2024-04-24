import Foundation // For the side effect of reexporting Darwin/Glibc
import struct Foundation.Date
import struct Foundation.TimeInterval

/// A clock for events that rely on date or duration relative to a point in time
@available(macOS 13.0, *)
public protocol TimeClock: Clock
 where Instant: DateProtocol, Duration == Instant.TimeInterval {
 associatedtype ClockType: Clock
 var clock: ClockType { get }
 func sleep(until deadline: Instant, tolerance: Duration?) async throws
}

@available(macOS 13.0, *)
public extension TimeClock where Instant == Date {}

// MARK: - Date Conformance
@available(macOS 13.0, *)
public extension TimeClock where Instant == Date {
 @_disfavoredOverload
 var minimumResolution: TimeInterval { 1e-9 }
 @_disfavoredOverload
 var now: Date { .distantFuture }
}

@available(macOS 13.0, *)
public extension TimeClock
 where ClockType == SuspendingClock, Instant == Date {
 func sleep(until deadline: Date, tolerance: TimeInterval? = nil) async throws {
  let duration: Swift.Duration =
   .seconds(
    deadline
     .timeIntervalSince(now == .distantFuture ? .now : now)
   )
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
public extension TimeClock
 where ClockType == ContinuousClock, Instant == Date {
 func sleep(until deadline: Date, tolerance: TimeInterval? = nil) async throws {
  let duration: Swift.Duration =
   .seconds(
    deadline
     .timeIntervalSince(now == .distantFuture ? .now : now)
   )
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
public struct SuspendingDateClock: TimeClock {
 public var now: Date { .now }
 public var minimumResolution: TimeInterval { 1e-9 }
 public var clock: SuspendingClock { .suspending }
}

@available(macOS 13.0, *)
public extension Clock where Self == SuspendingDateClock {
 static var suspendingDate: Self { Self() }
}

@available(macOS 13.0, *)
public struct ContinuousDateClock: TimeClock {
 public var now: Date { .now }
 public var minimumResolution: TimeInterval { 1e-9 }
 public var clock: ContinuousClock { .continuous }
}

@available(macOS 13.0, *)
public extension Clock where Self == ContinuousDateClock {
 static var continuousDate: Self { Self() }
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

// MARK: - Tick Conformance
@available(macOS 13.0, *)
public extension TimeClock where Instant.TimeInterval == Time {
 @_disfavoredOverload
 var minimumResolution: Time { .nanosecond }
 @_disfavoredOverload
 var now: Date { .distantFuture }
}

@available(macOS 13.0, *)
public extension TimeClock
 where ClockType == SuspendingClock, Instant == Tick {
 func sleep(until deadline: Tick, tolerance: Time? = nil) async throws {
  let duration: Swift.Duration =
   deadline
    .elapsedTime(since: now == .distantFuture ? .now : now).duration
  try await clock.sleep(
   until: .now.advanced(by: duration),
   tolerance: .seconds((tolerance ?? minimumResolution).rawValue)
  )
 }

 func sleep(tolerance: Time? = nil) async throws {
  try await clock.sleep(
   until: .now.advanced(by: Swift.Duration.seconds(now.timeIntervalSinceNow)),
   tolerance: .seconds((tolerance ?? minimumResolution).rawValue)
  )
 }
}

@available(macOS 13.0, *)
public extension TimeClock
 where ClockType == ContinuousClock, Instant == Tick {
 func sleep(until deadline: Tick, tolerance: Time? = nil) async throws {
  let duration: Swift.Duration =
   deadline
    .elapsedTime(since: now == .distantFuture ? .now : now).duration
  try await clock.sleep(
   until: .now.advanced(by: duration),
   tolerance: .seconds((tolerance ?? minimumResolution).rawValue)
  )
 }

 func sleep(tolerance: Time? = nil) async throws {
  try await clock.sleep(
   until: .now.advanced(by: Swift.Duration.seconds(now.timeIntervalSinceNow)),
   tolerance: .seconds((tolerance ?? minimumResolution).rawValue)
  )
 }
}

@available(macOS 13.0, *)
public struct SuspendingTickClock: TimeClock {
 public var now: Tick { .now }
 public var minimumResolution: Time { .nanosecond }
 public var clock: SuspendingClock { .suspending }
}

@available(macOS 13.0, *)
public extension Clock where Self == SuspendingDateClock {
 static var suspendingTick: Self { Self() }
}

@available(macOS 13.0, *)
public struct ContinuousTickClock: TimeClock {
 public var now: Tick { .now }
 public var minimumResolution: Time { .nanosecond }
 public var clock: ContinuousClock { .continuous }
}

@available(macOS 13.0, *)
public extension Clock where Self == ContinuousDateClock {
 static var continuousTick: Self { Self() }
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
