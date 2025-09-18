// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScheduleEngine",
    products: [
        .library(
            name: "ScheduleEngine",
            targets: ["ScheduleEngine"]),
        .executable(name: "ScheduleEngineDemo", targets: ["ScheduleEngineDemo"])

    ],
    targets: [
        .target(
            name: "ScheduleEngine"),
        .executableTarget(
              name: "ScheduleEngineDemo",
              dependencies: ["ScheduleEngine"]
            ),
        .testTarget(
            name: "ScheduleEngineTests",
            dependencies: ["ScheduleEngine"]
        ),
    ]
)
