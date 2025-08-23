// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftHDL",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SwiftHDL",
            targets: ["SwiftHDL"]),
        .library(
            name: "BundleDeriveMacros",
            targets: ["BundleDeriveMacros"]),
        .executable(
            name: "SwiftHDLExamples",
            targets: ["SwiftHDLExamples"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .target(
            name: "SwiftHDL",
            dependencies: [],
            path: "Sources/SwiftHDL"),
        .target(
            name: "BundleDeriveMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ]
        ),
        .executableTarget(
            name: "SwiftHDLExamples",
            dependencies: ["SwiftHDL"],
            path: "Sources/SwiftHDLExamples"),
    ]
)
