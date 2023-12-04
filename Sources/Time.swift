// https://www.github.com/swift-collections-benchmark
import Foundation

/// A replacement for duration
public struct Time {
 public let seconds: TimeInterval

 public init(_ seconds: TimeInterval) {
  precondition(!seconds.isNaN)
  self.seconds = seconds
 }
}

public extension Time {
 static let second = Time(1)
 static let millisecond = Time(1e-3)
 static let microsecond = Time(1e-6)
 static let nanosecond = Time(1e-9)
 static let picosecond = Time(1e-12)
 static let femtosecond = Time(1e-15)
 static let attosecond = Time(1e-18)
 static let zero = Time(0)
}

public extension Time {
 static func since(_ start: Tick) -> Time {
  Tick.now.elapsedTime(since: start)
 }
}

extension Time: RawRepresentable {
 public var rawValue: TimeInterval { seconds }

 public init(rawValue: TimeInterval) {
  self.seconds = rawValue
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
  if self.seconds == 0 { return "0" }
  if self < .attosecond { return String(format: "%.3gas", seconds * 1e18) }
  if self < .picosecond { return String(format: "%.3gfs", seconds * 1e15) }
  if self < .nanosecond { return String(format: "%.3gps", seconds * 1e12) }
  if self < .microsecond { return String(format: "%.3gns", seconds * 1e9) }
  if self < .millisecond { return String(format: "%.3gµs", seconds * 1e6) }
  if self < .second { return String(format: "%.3gms", seconds * 1e3) }
  if self.seconds < 1000 { return String(format: "%.3gs", seconds) }
  return String(format: "%gs", seconds.rounded())
 }

 public var typesetDescription: String {
  let spc = "\u{200A}"
  if self.seconds == 0 { return "0\(spc)s" }
  if self < .femtosecond { return String(format: "%.3g\(spc)as", seconds * 1e18) }
  if self < .picosecond { return String(format: "%.3g\(spc)fs", seconds * 1e15) }
  if self < .nanosecond { return String(format: "%.3g\(spc)ps", seconds * 1e12) }
  if self < .microsecond { return String(format: "%.3g\(spc)ns", seconds * 1e9) }
  if self < .millisecond { return String(format: "%.3g\(spc)µs", seconds * 1e6) }
  if self < .second { return String(format: "%.3g\(spc)ms", seconds * 1e3) }
  if self.seconds < 1000 { return String(format: "%.3g\(spc)s", seconds) }
  return String(format: "%g\(spc)s", seconds.rounded())
 }
}

extension Time: Codable {
 public init(from decoder: Decoder) throws {
  self.seconds = try TimeInterval(from: decoder)
 }

 public func encode(to encoder: Encoder) throws {
  try self.seconds.encode(to: encoder)
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

 private static let _floatingPointCharacterSet = CharacterSet(charactersIn: "+-0123456789.e")

 public init?(_ description: String) {
  var description = description.trimmingCharacters(in: .whitespacesAndNewlines)
  description = description.lowercased()
  if let i = description.rangeOfCharacter(from: Time._floatingPointCharacterSet.inverted) {
   let number = description.prefix(upTo: i.lowerBound)
   let suffix = description.suffix(from: i.lowerBound)
   guard let value = Double(number) else { return nil }
   guard let scale = Time._scaleFromSuffix[String(suffix)] else { return nil }
   self = Time(value * scale.seconds)
  }
  else {
   guard let value = Double(description) else { return nil }
   self = Time(value)
  }
 }
}

public extension Time {
 func amortized(over size: Size) -> Time {
  Time(seconds / TimeInterval(size.rawValue))
 }
}

extension Time {
 @usableFromInline
 func _orIfZero(_ time: Time) -> Time {
  self > .zero ? self : time
 }
}
