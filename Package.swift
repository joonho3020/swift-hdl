// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftHDL",
    platforms: [
        .macOS(.v13),
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
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .macro(
            name: "BundleDeriveMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SwiftHDL",
            dependencies: ["BundleDeriveMacros"],
            path: "Sources/SwiftHDL"),
        .executableTarget(
            name: "SwiftHDLExamples",
            dependencies: ["SwiftHDL", "BundleDeriveMacros"],
            path: "Sources/SwiftHDLExamples"),
    ]
)
