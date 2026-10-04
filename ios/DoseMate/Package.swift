// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DoseMate",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DoseMate",
            targets: ["DoseMate"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DoseMate",
            dependencies: [],
            path: "DoseMate"
        )
    ]
)
