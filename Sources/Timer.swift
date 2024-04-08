public final class StaticTimer: TimerProtocol {
 public init() {}
 public var fireDate: Tick = .distantFuture
 public func fire() { fireDate = .now }
 public func reset() { fireDate = .distantFuture }
}

public extension TimerProtocol where Self == StaticTimer {
 static var `static`: Self { Self() }
}

public struct Timer: TimerProtocol {
 @inlinable
 public init() {}
 public var fireDate: Tick = .distantFuture
}

public extension TimerProtocol where Self == Timer {
 static var standard: Self { Self() }
}
