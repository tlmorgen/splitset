// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SplitSetCore",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "SplitSetCore", targets: ["SplitSetCore"])
    ],
    targets: [
        .target(
            name: "SplitSetCore",
            path: "Sources/SplitSetCore"
        )
    ]
)
