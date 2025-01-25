// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Ricoh360Camera",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Ricoh360Camera",
            targets: ["Ricoh360CameraPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.2")
    ],
    targets: [
        .target(
            name: "Ricoh360CameraPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                "Alamofire"
            ],
            path: "ios/Sources/Ricoh360CameraPlugin"),
        .testTarget(
            name: "Ricoh360CameraPluginTests",
            dependencies: ["Ricoh360CameraPlugin"],
            path: "ios/Tests/Ricoh360CameraPluginTests")
    ]
)
