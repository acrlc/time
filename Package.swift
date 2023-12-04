// swift-tools-version:5.1
import PackageDescription

let package = Package(
 name: "Time",
 platforms: [.macOS(.v10_15), .iOS(.v13)],
 products: [.library(name: "Time", targets: ["Time"])],
 targets: [
  .target(name: "Time", path: "Sources"),
  .testTarget(name: "TimeTests", dependencies: ["Time"])
 ]
)
