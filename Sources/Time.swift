import Foundation

/// A unit of time based in ``Double`` and used to .
public struct Time: Sendable {
 let seconds: TimeInterval

 public init(_ seconds: TimeInterval) {
  precondition(
   !seconds.isNaN, "\(Self.self) cannot be initialized as nan"
  )
  self.seconds = seconds
 }
}

public extension Time {
 static let zero = Time(0)
 static let second = Time(1)
 static let millisecond = Time(1e-3)
 static let microsecond = Time(1e-6)
 static let nanosecond = Time(1e-9)
 static let picosecond = Time(1e-12)
 static let femtosecond = Time(1e-15)
 static let attosecond = Time(1e-18)
}

public extension Time {
 static func since(_ start: Tick) -> Time {
  Tick.now.elapsedTime(since: start)
 }
}

extension Time: RawRepresentable {
 public var rawValue: TimeInterval { seconds }

 public init(rawValue: TimeInterval) {
  self.init(rawValue)
 }
}

extension Time: FloatingPoint, ExpressibleByFloatLiteral {
 public init(signOf lhs: Time, magnitudeOf rhs: Time) {
  self.init(TimeInterval(signOf: lhs.seconds, magnitudeOf: rhs.seconds))
 }

 public init(_ value: some BinaryInteger) {
  self.init(TimeInterval(value))
 }

 public init?(exactly value: some BinaryInteger) {
  self.init(TimeInterval(value))
 }

 public init(integerLiteral value: Int) {
  self.init(value)
 }

 public init(floatLiteral value: TimeInterval) {
  self.init(value)
 }

 public static var radix: Int {
  TimeInterval.radix
 }

 public static var nan: Time {
  Time(.nan)
 }

 public static var signalingNaN: Time {
  Time(.signalingNaN)
 }

 public static var infinity: Time {
  Time(TimeInterval.infinity)
 }

 public static var greatestFiniteMagnitude: Time {
  Time(TimeInterval.greatestFiniteMagnitude)
 }

 public static var pi: Time {
  Time(TimeInterval.pi)
 }

 public var ulp: Time {
  Time(seconds.ulp)
 }

 public static var leastNormalMagnitude: Time {
  Time(TimeInterval.leastNormalMagnitude)
 }

 public static var leastNonzeroMagnitude: Time {
  Time(TimeInterval.leastNonzeroMagnitude)
 }

 public var sign: FloatingPointSign {
  seconds.sign
 }

 public var exponent: Int {
  seconds.exponent
 }

 public var significand: Time {
  Time(seconds.significand)
 }

 public mutating func formRemainder(dividingBy other: Time) {
  var value = seconds
  value.formRemainder(dividingBy: other.seconds)
 }

 public mutating func formTruncatingRemainder(dividingBy other: Time) {
  var value = seconds
  value.formTruncatingRemainder(dividingBy: other.seconds)
  self = Time(value)
 }

 public mutating func formSquareRoot() {
  var value = seconds
  value.formSquareRoot()
  self = Time(value)
 }

 public mutating func addProduct(_ lhs: Time, _ rhs: Time) {
  var value = seconds
  value.addProduct(lhs.seconds, rhs.seconds)
  self = Time(value)
 }

 public mutating func round(_ rule: FloatingPointRoundingRule) {
  var value = seconds
  value.round(rule)
  self = Time(value)
 }

 public var nextUp: Time {
  Time(seconds.nextUp)
 }

 public var nextDown: Time {
  Time(seconds.nextDown)
 }

 public func isEqual(to other: Time) -> Bool {
  seconds.isEqual(to: other.seconds)
 }

 public func isLess(than other: Time) -> Bool {
  seconds.isLess(than: other.seconds)
 }

 public func isLessThanOrEqualTo(_ other: Time) -> Bool {
  seconds.isLessThanOrEqualTo(other.seconds)
 }

 public func isTotallyOrdered(belowOrEqualTo other: Time) -> Bool {
  seconds.isTotallyOrdered(belowOrEqualTo: other.seconds)
 }

 public var isNormal: Bool {
  seconds.isNormal
 }

 public var isFinite: Bool {
  seconds.isFinite
 }

 public var isZero: Bool {
  seconds.isZero
 }

 public var isSubnormal: Bool {
  seconds.isSubnormal
 }

 public var isInfinite: Bool {
  seconds.isInfinite
 }

 public var isNaN: Bool {
  false
 }

 public var isSignalingNaN: Bool {
  false
 }

 public var isCanonical: Bool {
  seconds.isCanonical
 }

 public init(sign: FloatingPointSign, exponent: Int, significand: Time) {
  self.init(
   TimeInterval(
    sign: sign, exponent: exponent,
    significand: significand.seconds.significand
   )
  )
 }

 public func distance(to other: Time) -> TimeInterval {
  seconds.distance(to: other.seconds)
 }

 public func advanced(by n: TimeInterval) -> Time {
  Time(seconds.distance(to: n))
 }

 public var magnitude: Time {
  Time(seconds.magnitude)
 }

 public static func * (lhs: Time, rhs: Time) -> Time {
  Time(lhs.seconds * rhs.seconds)
 }

 public static func + (lhs: Time, rhs: Time) -> Time {
  Time(lhs.seconds + rhs.seconds)
 }

 public static func - (lhs: Time, rhs: Time) -> Time {
  Time(lhs.seconds - rhs.seconds)
 }

 public static func / (lhs: Time, rhs: Time) -> Time {
  Time(lhs.seconds / rhs.seconds)
 }

 public static func * (lhs: Time, rhs: Int) -> Time {
  Time(lhs.seconds * TimeInterval(rhs))
 }

 public static func / (lhs: Time, rhs: Int) -> Time {
  Time(lhs.seconds / TimeInterval(rhs))
 }

 public static func / (lhs: Time, rhs: Time) -> TimeInterval {
  lhs.seconds / rhs.seconds
 }

 public static func *= (lhs: inout Time, rhs: Time) {
  lhs = lhs * rhs
 }

 public static func /= (lhs: inout Time, rhs: Time) {
  lhs = lhs / rhs
 }
}

extension Time: Equatable {
 public static func == (left: Self, right: Self) -> Bool {
  left.seconds == right.seconds
 }
}

extension Time: Hashable {
 public func hash(into hasher: inout Hasher) {
  hasher.combine(seconds)
 }
}

extension Time: Comparable {
 public static func < (left: Self, right: Self) -> Bool {
  left.seconds < right.seconds
 }
}

extension Time: CustomStringConvertible {
 public var description: String {
  if seconds == 0 {
   return "0"
  }
  if self < .attosecond {
   return String(format: "%.3gas", seconds * 1e18)
  }
  if self < .picosecond {
   return String(format: "%.3gfs", seconds * 1e15)
  }
  if self < .nanosecond {
   return String(format: "%.3gps", seconds * 1e12)
  }
  if self < .microsecond {
   return String(format: "%.3gns", seconds * 1e9)
  }
  if self < .millisecond {
   return String(format: "%.3gµs", seconds * 1e6)
  }
  if self < .second {
   return String(format: "%.3gms", seconds * 1e3)
  }
  if seconds < 1000 {
   return String(format: "%.3gs", seconds)
  }
  return String(format: "%gs", seconds.rounded())
 }

 public var typesetDescription: String {
  let spc = "\u{200A}"
  if seconds == 0 {
   return "0\(spc)s"
  }
  if self < .femtosecond {
   return String(format: "%.3g\(spc)as", seconds * 1e18)
  }
  if self < .picosecond {
   return String(format: "%.3g\(spc)fs", seconds * 1e15)
  }
  if self < .nanosecond {
   return String(format: "%.3g\(spc)ps", seconds * 1e12)
  }
  if self < .microsecond {
   return String(format: "%.3g\(spc)ns", seconds * 1e9)
  }
  if self < .millisecond {
   return String(format: "%.3g\(spc)µs", seconds * 1e6)
  }
  if self < .second {
   return String(format: "%.3g\(spc)ms", seconds * 1e3)
  }
  if seconds < 1000 {
   return String(format: "%.3g\(spc)s", seconds)
  }
  return String(format: "%g\(spc)s", seconds.rounded())
 }
}

extension Time: Codable {
 public init(from decoder: Decoder) throws {
  seconds = try TimeInterval(from: decoder)
 }

 public func encode(to encoder: Encoder) throws {
  try seconds.encode(to: encoder)
 }
}

extension Time {
 private static let _scaleFromSuffix: [String: Time] = [
  "": .second,
  "s": .second,
  "ms": .millisecond,
  "µs": .microsecond,
  "us": .microsecond,
  "ns": .nanosecond,
  "ps": .picosecond,
  "fs": .femtosecond,
  "as": .attosecond
 ]

 private static let _floatingPointCharacterSet =
  CharacterSet(charactersIn: "+-0123456789.e")

 public init?(_ description: String) {
  var description = description.trimmingCharacters(in: .whitespacesAndNewlines)
  description = description.lowercased()
  if
   let i = description
    .rangeOfCharacter(from: Time._floatingPointCharacterSet.inverted) {
   let number = description.prefix(upTo: i.lowerBound)
   let suffix = description.suffix(from: i.lowerBound)
   guard let value = TimeInterval(number) else {
    return nil
   }
   guard let scale = Time._scaleFromSuffix[String(suffix)] else {
    return nil
   }
   self = Time(value * scale.seconds)
  }
  else {
   guard let value = TimeInterval(description) else {
    return nil
   }
   self = Time(value)
  }
 }
}

public extension Time {
 func amortized(over size: Size) -> Time {
  Time(seconds / TimeInterval(size._value))
 }
}

extension Time {
 @usableFromInline
 func _orIfZero(_ time: Time) -> Time {
  self > .zero ? self : time
 }
}
