// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Richon360CapacitorPlugin",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Richon360CapacitorPlugin",
            targets: ["Ricoh360CameraPluginPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Ricoh360CameraPluginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/Ricoh360CameraPluginPlugin"),
        .testTarget(
            name: "Ricoh360CameraPluginPluginTests",
            dependencies: ["Ricoh360CameraPluginPlugin"],
            path: "ios/Tests/Ricoh360CameraPluginPluginTests")
    ]
)