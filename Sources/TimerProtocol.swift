public protocol TimerProtocol {
 /// Time the object first first fired
 var fireDate: Tick { get set }
 /// Sets the start time
 mutating func fire()
 /// Resets the time
 mutating func reset()
 init()

 init(
  repeats: Bool, _ closure: @escaping (Self) throws -> Void
 ) rethrows
 init(
  repeats: Bool, _ closure: @Sendable @escaping (Self) async throws -> Void
 ) async rethrows
}

public extension TimerProtocol {
 @_disfavoredOverload
 @inlinable
 var isValid: Bool {
  fireDate == .distantFuture || fireDate != .distantPast
 }

 @_disfavoredOverload
 @inlinable
 mutating func fire() { fireDate = .now }
 @_disfavoredOverload
 @inlinable
 mutating func reset() { fireDate = .distantFuture }
 @_disfavoredOverload
 @inlinable
 mutating func invalidate() { fireDate = .distantPast }

 @inlinable
 @discardableResult
 init(
  repeats: Bool, _ closure: @escaping (Self) throws -> Void
 ) rethrows {
  self.init()
  try time(repeats: repeats, closure)
 }

 @inlinable
 @discardableResult
 init(
  repeats: Bool, _ closure: @Sendable @escaping (Self) async throws -> Void
 ) async rethrows {
  self.init()
  try await time(repeats: repeats, closure)
 }

 @inlinable
 mutating func time(
  repeats: Bool = false,
  _ closure: @escaping (Self) throws -> Void
 ) rethrows {
  func execute() throws {
   defer { self.reset() }
   fire()
   try closure(self)
  }

  if repeats {
   while true {
    try execute()
   }
  } else {
   try execute()
  }
 }

 @inlinable
 mutating func time(
  repeats: Bool = false,
  _ closure: @escaping (Self) async throws -> Void
 ) async rethrows {
  func execute() async throws {
   defer { self.reset() }
   fire()
   try await closure(self)
  }

  if repeats {
   while true {
    try await execute()
   }
  } else {
   try await execute()
  }
 }

 @inlinable
 mutating func timeResult<A>(
  _ closure: @escaping (Self) throws -> A
 ) rethrows -> A {
  defer { self.reset() }
  fire()
  return try closure(self)
 }

 @inlinable
 mutating func timeResult<A>(
  _ closure: @escaping (Self) async throws -> A
 ) async rethrows -> A {
  defer { self.reset() }
  fire()
  return try await closure(self)
 }

 @inlinable
 var elapsed: Time { Time.since(fireDate)._orIfZero(Tick.resolution) }

 @inlinable
 mutating func measure(
  _ work: () throws -> Void
 ) rethrows -> Time {
  defer { self.reset() }
  fire()
  try work()
  return elapsed
 }

 @inlinable
 mutating func measure(
  _ work: () async throws -> Void
 ) async rethrows -> Time {
  defer { self.reset() }
  fire()
  try await work()
  return elapsed
 }

 @inlinable
 var description: String { elapsed.description }
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
