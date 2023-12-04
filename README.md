#### Library for time, which intends to bridge the gap between time, benchmarking performance, and protocols that use time and iteration size as a metric

### Usage
```swift
var timer: TimerProtocol = .standard
timer.fire() // records the time when started
sleep(2)

// read elapsed time
let time = timer.elapsed

print(time)
timer.reset() // resets the timer, if needed
```
Includes some functions for measuring time
```swift
let timer: TimerProtocol = .static
let measured = timer.measure { sleep(1) }

print(measured) // prints the measured time

withTimer { timer in
 sleep(3)
 print(timer) // prints the elapsed time
}
```
### Sources
[swift-collection-benchmarks](https://www.github.com/apple/swift-collections-benchmarks) for `Size`,`Tick`, and `Time` 
