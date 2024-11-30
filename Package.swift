// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CURLSession",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CURLSession",
            targets: ["CURLSession"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CURLSession",
            dependencies: [
                "CurlSwift",
            ]
        ),
        .target(
            name: "CurlSwift",
            dependencies: ["libcurl"],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("ldap", .when(platforms: [.macOS])),
                .linkedFramework("SystemConfiguration", .when(platforms: [.macOS])),
            ]
        ),
        .testTarget(
            name: "CURLSessionTests",
            dependencies: [
                "CURLSession",
            ]
        ),
        .binaryTarget(
            name: "libcurl",
            url: "https://github.com/greatfire/curl-apple/releases/download/8.11.0/curl.xcframework.zip",
            checksum: "8cd5792a1be420adb4dc18d73315df1efc8b56d25d801375b4b6ce70092c2282"
        ),
    ]
)
