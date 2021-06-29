// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "AnyCodeReader",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "AnyCodeReader", targets: ["AnyCodeReader"]),
    ],
    targets: [
        .target(
            name: "AnyCodeReader",
            path: "AnyCodeReader",
            exclude: []
        )
    ]
)
