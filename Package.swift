// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SwiftDux",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "SwiftDux", targets: ["SwiftDux"]),
        .library(name: "SwiftDuxTestComponents", targets: ["SwiftDuxTestComponents"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick.git", exact: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", exact: "9.2.1"),
    ],
    targets: [
        .target(
            name: "SwiftDux",
            path: "SwiftDux",
            exclude: ["Info.plist", "SwiftDux.h"]
        ),
        .target(
            name: "SwiftDuxTestComponents",
            dependencies: ["SwiftDux"],
            path: "SwiftDuxTestComponents",
            exclude: ["Info.plist", "SwiftDuxTestComponents.h"]
        ),
        .testTarget(
            name: "SwiftDuxTests",
            dependencies: [
                "SwiftDux",
                "SwiftDuxTestComponents",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            path: "SwiftDuxTests",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "SwiftDuxExtensionsTests",
            dependencies: [
                "SwiftDux",
                "SwiftDuxTestComponents",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ],
            path: "SwiftDuxExtensionsTests"
        ),
    ]
)
