// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftHDL",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SwiftHDL",
            targets: ["SwiftHDL"]),
        .executable(
            name: "SwiftHDLExamples",
            targets: ["SwiftHDLExamples"]),
    ],
    dependencies: [
        // Add dependencies here as needed
    ],
    targets: [
        .target(
            name: "SwiftHDL",
            dependencies: [],
            path: "Sources/SwiftHDL"),
        .executableTarget(
            name: "SwiftHDLExamples",
            dependencies: ["SwiftHDL"],
            path: "Sources/SwiftHDLExamples"),
    ]
)
