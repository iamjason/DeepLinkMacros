// swift-tools-version: 6.0
//
//  Package.swift
//  BobsBurgersDemo
//
//  A multi-tabbed iOS demo app showing how to integrate DeepLinkMacros
//  with PointFree's CasePathable for Bob's Burgers themed navigation.
//

import PackageDescription

let package = Package(
    name: "BobsBurgersDemo",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "BobsBurgersDemo",
            targets: ["BobsBurgersDemo"]
        ),
        .executable(
            name: "BobsBurgersApp",
            targets: ["BobsBurgersApp"]
        ),
    ],
    dependencies: [
        // DeepLinkMacros - using full GitHub URL like a real-world implementation
        .package(url: "https://github.com/iamjason/DeepLinkMacros.git", branch: "main"),

        // PointFree's CasePathable for ergonomic enum handling
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "BobsBurgersDemo",
            dependencies: [
                .product(name: "DeepLinkRouting", package: "DeepLinkMacros"),
                .product(name: "CasePaths", package: "swift-case-paths"),
            ]
        ),
        .executableTarget(
            name: "BobsBurgersApp",
            dependencies: ["BobsBurgersDemo"]
        ),
        .testTarget(
            name: "BobsBurgersDemoTests",
            dependencies: ["BobsBurgersDemo"]
        ),
    ]
)
