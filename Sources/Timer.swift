public final class StaticTimer: TimerProtocol {
 public init() {}
 public var fireDate: Tick = .distantFuture
 public func fire() { self.fireDate = .now }
 public func reset() { self.fireDate = .distantPast }
}

public extension TimerProtocol where Self == StaticTimer {
 static var `static`: Self { Self() }
}

public struct Timer: TimerProtocol {
 @inlinable public init() {}
 public var fireDate: Tick = .distantFuture
}

public extension TimerProtocol where Self == Timer {
 static var standard: Self { Self() }
}

