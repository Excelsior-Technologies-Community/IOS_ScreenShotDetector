// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ScreenshotDetectorKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ScreenshotDetectorKit",
            targets: ["ScreenshotDetectorKit"]
        ),
    ],
    targets: [
        .target(
            name: "ScreenshotDetectorKit",
            dependencies: [],
            path: "Sources/ScreenshotDetectorKit"
        ),
        .testTarget(
            name: "ScreenshotDetectorKitTests",
            dependencies: ["ScreenshotDetectorKit"],
            path: "Tests/ScreenshotDetectorKitTests"
        ),
    ]
)


