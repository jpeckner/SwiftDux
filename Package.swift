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
            ],
            path: "SwiftDuxTests",
            exclude: ["Info.plist"]
        ),
    ]
)
