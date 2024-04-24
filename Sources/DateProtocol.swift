import struct Foundation.Date

public protocol DateProtocol: Sendable {
 associatedtype TimeInterval
 var timeIntervalSinceNow: TimeInterval { get }
 static var distantFuture: Self { get }
 static var distantPast: Self { get }
}

extension Date: DateProtocol {}
