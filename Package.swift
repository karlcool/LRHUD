// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LRHUD",
    products: [
        .library(
            name: "LRHUD",
            targets: ["LRHUD"]),
    ],
    targets: [
        .target(
            name: "LRHUD",
            path: "LRHUD/Class")
    ]
)
