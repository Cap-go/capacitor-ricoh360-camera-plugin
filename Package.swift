// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Richon360Camera",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Richon360Camera",
            targets: ["Ricoh360CameraPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Ricoh360CameraPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "THETAClient")
            ],
            path: "ios/Sources/Ricoh360CameraPlugin"),
        .testTarget(
            name: "Ricoh360CameraPluginTests",
            dependencies: ["Ricoh360CameraPlugin"],
            path: "ios/Tests/Ricoh360CameraPluginTests")
        .binaryTarget(
            name: "THETAClient",
            path: "submodules/theta-client/kotlin-multiplatform/build/cocoapods/publish/release/THETAClient.xcframework",
        )
    ]
)
