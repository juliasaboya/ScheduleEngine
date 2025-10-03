// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScheduleEngine",
    products: [
        .library(
            name: "SuggestionEngine",
            targets: ["SuggestionEngine"]),

    ],
    targets: [
        .target(
            name: "SuggestionEngine",
            dependencies: []),
        .testTarget(
            name: "SuggestionEngineTests",
            dependencies: ["SuggestionEngine"]),
    ]
)
