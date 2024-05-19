#if !USE_FOUNDATION_DATE && (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
import Foundation

/// A point in time based on a reference and used to measure relative events.
public struct Tick: Equatable, Hashable, DateProtocol {
 private let _value: timespec

 fileprivate init(_value: timespec) {
  self._value = _value
 }

 public static var now: Tick {
  guard #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) else {
   fatalError("Please enable USE_FOUNDATION_DATE")
  }
  var now = timespec()
  let r = clock_gettime(CLOCK_MONOTONIC_RAW, &now)
  precondition(r == 0, "clock_gettime failure")
  return Tick(_value: now)
 }

 public static var resolution: Time {
  guard #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) else {
   fatalError("Please enable USE_FOUNDATION_DATE")
  }
  var res = timespec()
  let r = clock_getres(CLOCK_MONOTONIC_RAW, &res)
  precondition(r == 0, "clock_getres failure")
  return Tick(_value: res).elapsedTime(
   since: Tick(_value: timespec(tv_sec: 0, tv_nsec: 0))
  )
 }

 public static let distantPast =
  Tick(_value: timespec(tv_sec: -.max, tv_nsec: -.max))
 public static let distantFuture =
  Tick(_value: timespec(tv_sec: .max, tv_nsec: .max))

 public func elapsedTime(since start: Tick) -> Time {
  let s = Double(_value.tv_sec - start._value.tv_sec)
  let ns = Double(_value.tv_nsec - start._value.tv_nsec)

  return Time(s + ns / 1e9)
 }

 public func advanced(by duration: Time) -> Tick {
  let seconds = duration.seconds
  let rounded = seconds.rounded(.down)
  let remainder = seconds.remainder(dividingBy: rounded)
  return Tick(
   _value: timespec(
    tv_sec: _value.tv_sec + (rounded > 0 ? Int(rounded) : 0),
    tv_nsec: _value.tv_nsec + (remainder > 0 ? Int(remainder * 1e9) : 0)
   )
  )
 }

 public func duration(to other: Tick) -> Time {
  let s = Double(other._value.tv_sec - _value.tv_sec)
  let ns = Double(other._value.tv_nsec - _value.tv_nsec)
  return Time(s + ns / 1e9)
 }

 public static func == (lhs: Tick, rhs: Tick) -> Bool {
  lhs._value.tv_sec == rhs._value.tv_sec &&
   lhs._value.tv_nsec == rhs._value.tv_nsec
 }

 public static func < (lhs: Tick, rhs: Tick) -> Bool {
  lhs._value.tv_sec <= rhs._value.tv_sec &&
   lhs._value.tv_nsec <= rhs._value.tv_nsec
 }
}

extension timespec: Hashable {
 public static func == (lhs: timespec, rhs: timespec) -> Bool {
  lhs.tv_sec == rhs.tv_sec && lhs.tv_nsec == rhs.tv_nsec
 }

 public func hash(into hasher: inout Hasher) {
  hasher.combine(tv_sec)
  hasher.combine(tv_nsec)
 }
}

#else
import struct Foundation.Date

public struct Tick: Equatable, Hashable, DateProtocol {
 private let _value: Date

 fileprivate init(_value: Date) {
  self._value = _value
 }

 public static var now: Tick {
  Tick(_value: Date())
 }

 public static var resolution: Time {
  .nanosecond
 }

 public static let distantPast = Tick(_value: .distantPast)
 public static let distantFuture = Tick(_value: .distantFuture)

 public func elapsedTime(since start: Tick) -> Time {
  Time(_value.timeIntervalSince(start._value))
 }

 public func advanced(by duration: Time) -> Tick {
  Tick(_value: _value.advanced(by: duration.rawValue))
 }

 public func duration(to other: Tick) -> Time {
  Time(_value.duration(to: other._value))
 }

 public static func == (lhs: Tick, rhs: Tick) -> Bool {
  lhs._value == rhs._value
 }

 public static func < (lhs: Tick, rhs: Tick) -> Bool {
  lhs._value < rhs._value
 }
}
#endif

public extension Tick {
 var timeIntervalSinceNow: Time { elapsedTime(since: .now) }

 static func + (lhs: Tick, rhs: Time) -> Tick {
  lhs.advanced(by: rhs)
 }

 static func += (lhs: inout Tick, rhs: Time) {
  lhs = lhs.advanced(by: rhs)
 }
}
