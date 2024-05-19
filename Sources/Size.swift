public struct Size {
 let _value: UInt

 public init(_ value: UInt) {
  _value = value
 }
}

extension Size: RawRepresentable {
 public var rawValue: UInt { _value }

 public init(rawValue: UInt) {
  self.init(rawValue)
 }
}

extension Size: CustomStringConvertible {
 public var description: String {
  let v = Double(_value)
  return
   _value >= 1 << 40
    ? String(format: "%.3gT", v * 0x1p-40)
    : _value >= 1 << 30
     ? String(format: "%.3gG", v * 0x1p-30)
     : _value >= 1 << 20
      ? String(format: "%.3gM", v * 0x1p-20)
      : _value >= 1024
       ? String(format: "%.3gk", v * 0x1p-10)
       : "\(_value)"
 }
}

extension Size: CodingKey {
 public init?(intValue: Int) {
  self.init(intValue)
 }

 public init?(stringValue: String) {
  guard let size = Size(stringValue) else {
   return nil
  }
  self = size
 }

 public var intValue: Int? { Int(_value) }
 public var stringValue: String { "\(_value)" }
}

extension Size: Codable {
 public init(from decoder: Decoder) throws {
  let container = try decoder.singleValueContainer()
  _value = try container.decode(UInt.self)
 }

 public func encode(to encoder: Encoder) throws {
  var container = encoder.singleValueContainer()
  try container.encode(_value)
 }
}

public extension Size {
 init?(_ string: String) {
  var position = string.startIndex

  // Parse digits
  loop: while position != string.endIndex {
   switch string[position] {
   case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
    string.formIndex(after: &position)
   default:
    break loop
   }
  }
  let digits = string.prefix(upTo: position)
  guard let value = UInt(digits, radix: 10) else {
   return nil
  }

  // Parse optional suffix
  let suffix = string.suffix(from: position)
  switch suffix {
  case "": _value = value
  case "k", "K": _value = value << 10
  case "m", "M": _value = value << 20
  case "g", "G": _value = value << 30
  case "t", "T": _value = value << 40
  default: return nil
  }
 }
}

extension Size: UnsignedInteger, Comparable {
 public init?(exactly source: some BinaryFloatingPoint) {
  guard let value = UInt(exactly: source) else { return nil }
  self.init(value)
 }

 public init(_ source: some BinaryFloatingPoint) {
  self.init(UInt(source))
 }

 public init(_ source: some BinaryInteger) {
  self.init(UInt(source))
 }

 public init?(exactly source: some BinaryInteger) {
  guard let value = UInt(exactly: source) else { return nil }
  self.init(value)
 }

 public init(truncatingIfNeeded source: some BinaryInteger) {
  self.init(UInt(truncatingIfNeeded: source))
 }

 public init(clamping source: some BinaryInteger) {
  self.init(UInt(clamping: source))
 }

 public init(integerLiteral value: UInt) {
  self.init(value)
 }

 public static var zero: Size {
  Size(0)
 }

 public static var max: Size {
  Size(UInt.max)
 }

 public static var min: Size {
  Size(UInt.min)
 }

 public static var isSigned: Bool {
  false
 }

 public static func < (lhs: Size, rhs: Size) -> Bool {
  lhs._value < rhs._value
 }

 public static func + (lhs: Size, rhs: Size) -> Size {
  Size(lhs._value + rhs._value)
 }

 public static func - (lhs: Size, rhs: Size) -> Size {
  Size(lhs._value - rhs._value)
 }

 public static func / (lhs: Size, rhs: Size) -> Size {
  Size(lhs._value / rhs._value)
 }

 public static func % (lhs: Size, rhs: Size) -> Size {
  Size(lhs._value % rhs._value)
 }

 public static func %= (lhs: inout Size, rhs: Size) {
  var value = lhs._value
  value %= rhs._value
  lhs = Size(value)
 }

 public static func * (lhs: Size, rhs: Size) -> Size {
  Size(lhs._value * rhs._value)
 }

 public static func &= (lhs: inout Size, rhs: Size) {
  var value = lhs._value
  value &= rhs._value
  lhs = Size(value)
 }

 public static func |= (lhs: inout Size, rhs: Size) {
  var value = lhs._value
  value |= rhs._value
  lhs = Size(value)
 }

 public static func ^= (lhs: inout Size, rhs: Size) {
  var value = lhs._value
  value ^= rhs._value
  lhs = Size(value)
 }

 public static func /= (lhs: inout Size, rhs: Size) {
  var value = lhs._value
  value /= rhs._value
  lhs = Size(value)
 }

 public static func *= (lhs: inout Size, rhs: Size) {
  var value = lhs._value
  value *= rhs._value
  lhs = Size(value)
 }

 public static func ~= (lhs: Size, rhs: Size) -> Bool {
  lhs._value ~= rhs._value
 }

 public static func == (lhs: Size, rhs: Size) -> Bool {
  lhs._value == rhs._value
 }

 public static prefix func ~ (x: Size) -> Size {
  Size(~x._value)
 }

 public static func >>= (lhs: inout Size, rhs: some BinaryInteger) {
  var value = lhs._value
  value >>= rhs
  lhs = Size(value)
 }

 public static func <<= (lhs: inout Size, rhs: some BinaryInteger) {
  var value = lhs._value
  value <<= rhs
  lhs = Size(value)
 }

 public var bitWidth: Int {
  _value.bitWidth
 }

 public var words: UInt.Words {
  _value.words
 }

 public var trailingZeroBitCount: Int {
  _value.trailingZeroBitCount
 }

 public var nonzeroBitCount: Int {
  _value.nonzeroBitCount
 }

 public var leadingZeroBitCount: Int {
  _value.leadingZeroBitCount
 }

 public var byteSwapped: Size {
  Size(_value.byteSwapped)
 }

 public var magnitude: Size { self }
}

extension FixedWidthInteger {
 var _minimumBitWidth: Int {
  Self.bitWidth - leadingZeroBitCount
 }
}

public extension Size {
 private static func _checkSignificantDigits(_ digits: Int) {
  precondition(digits >= 1 && digits <= UInt.bitWidth)
 }

 func roundedDown(significantDigits digits: Int) -> Size {
  Self._checkSignificantDigits(digits)
  let mask: UInt = (0 &- 1) << (_value._minimumBitWidth - digits)
  return Size(_value & mask)
 }

 func nextUp(significantDigits digits: Int) -> Size {
  Self._checkSignificantDigits(digits)

  let shift = _value._minimumBitWidth - digits
  let mask: UInt = (0 &- 1) << shift
  guard shift >= 0 else {
   return Size(_value + 1)
  }
  return Size((_value + (1 << shift)) & mask)
 }

 static func sizes(
  for range: ClosedRange<Size>,
  significantDigits digits: Int
 ) -> [Size] {
  _checkSignificantDigits(digits)
  var result: [Size] = []
  var value = range.lowerBound.roundedDown(significantDigits: digits)
  while value < range.lowerBound {
   value = value.nextUp(significantDigits: digits)
  }
  while value <= range.upperBound {
   result.append(value)
   value = value.nextUp(significantDigits: digits)
  }
  return result
 }
}

extension Size: Sequence {
 public func makeIterator() -> Iterator {
  Iterator(limit: _value)
 }

 public struct Iterator: IteratorProtocol {
  var current: UInt = 0
  let limit: UInt
  public mutating func next() -> UInt? {
   guard current < limit else {
    return nil
   }
   current += 1
   return current
  }
 }
}
