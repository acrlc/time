public protocol TimerProtocol {
 /// Time the object first first fired
 var fireDate: Tick { get set }
 /// Sets the start time
 mutating func fire()
 /// Resets the time
 mutating func reset()
 init()

 init(
  repeats: Bool,
  count: Int,
  _ closure: @escaping (Self) throws -> Void
 ) throws
 init(
  repeats: Bool,
  count: Int,
  _ closure: @Sendable @escaping (Self) async throws -> Void
 ) async throws
}

public extension TimerProtocol {
 @_disfavoredOverload
 @inlinable
 var isValid: Bool { self.fireDate == .distantFuture }
 @_disfavoredOverload
 @inlinable
 mutating func fire() { self.fireDate = .now }
 @_disfavoredOverload
 @inlinable
 mutating func reset() { self.fireDate = .distantFuture }
 @_disfavoredOverload
 @inlinable
 mutating func invalidate() { self.fireDate = .distantPast }

 @inlinable
 @discardableResult
 init(
  repeats: Bool = false,
  count: Int = 2,
  _ closure: @escaping (Self) throws -> Void
 ) throws {
  self.init()
  try self.time(repeats: repeats, count: count, closure)
 }

 @inlinable
 @discardableResult
 init(
  repeats: Bool,
  count: Int,
  _ closure: @escaping (Self) async throws -> Void
 ) async throws {
  self.init()
  try await self.time(repeats: repeats, count: count, closure)
 }

 @inlinable
 mutating func time(
  repeats: Bool = false,
  count: Int = 2,
  _ closure: @escaping (Self) throws -> Void
 ) rethrows {
  func execute() throws {
   defer { self.reset() }
   self.fire()
   try closure(self)
  }

  if repeats {
   let count = (0 ..< count)
   guard !count.isEmpty else { return }
   for _ in count { try execute() }
  } else { try execute() }
 }

 @inlinable
 mutating func time(
  repeats: Bool = false,
  count: Int = 2,
  _ closure: @escaping (Self) async throws -> Void
 ) async rethrows {
  func execute() async throws {
   defer { self.reset() }
   self.fire()
   try await closure(self)
  }

  if repeats {
   let count = (0 ..< count)
   guard !count.isEmpty else { return }
   for _ in count { try await execute() }
  } else { try await execute() }
 }

 @inlinable
 mutating func timeResult<A>(
  _ closure: @escaping (Self) throws -> A
 ) rethrows -> A {
  defer { self.reset() }
  self.fire()
  return try closure(self)
 }

 @inlinable
 mutating func timeResult<A>(
  _ closure: @escaping (Self) async throws -> A
 ) async rethrows -> A {
  defer { self.reset() }
  self.fire()
  return try await closure(self)
 }

 @inlinable
 var elapsed: Time { Time.since(self.fireDate)._orIfZero(Tick.resolution) }

 @inlinable
 mutating func measure(
  _ work: () throws -> Void
 ) rethrows -> Time {
  defer { self.reset() }
  self.fire()
  try work()
  return elapsed
 }

 @inlinable
 mutating func measure(
  _ work: () async throws -> Void
 ) async rethrows -> Time {
  defer { self.reset() }
  self.fire()
  try await work()
  return elapsed
 }

 @inlinable var description: String { elapsed.description }
}

@inlinable
@discardableResult
public func withTimer<A>(
 _ timer: Timer = .standard,
 _ closure: @escaping (Timer) throws -> A
) rethrows -> A {
 var timer = timer
 return try timer.timeResult(closure)
}

@inlinable
@_disfavoredOverload
@discardableResult
public func withTimer<Timer: TimerProtocol, A>(
 _ timer: Timer,
 _ closure: @escaping (Timer) throws -> A
) rethrows -> A {
 var timer = timer
 return try timer.timeResult(closure)
}

@inlinable
@discardableResult
public func withTimer<A>(
 _ timer: Timer = .standard,
 _ closure: @Sendable @escaping (Timer) async throws -> A
) async rethrows -> A {
 var timer = timer
 return try await timer.timeResult(closure)
}

@inlinable
@_disfavoredOverload
@discardableResult
public func withTimer<Timer: TimerProtocol, A>(
 _ timer: Timer = Timer(),
 _ closure: @Sendable @escaping (Timer) async throws -> A
) async rethrows -> A {
 var timer = timer
 return try await timer.timeResult(closure)
}
