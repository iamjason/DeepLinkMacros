// swift-tools-version: 5.9
//
//  Package.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "DeepLinkMacros",
  platforms: [.iOS(.v15), .macOS(.v12)],
  products: [
    .library(
      name: "DeepLinkRouting",
      targets: ["DeepLinkRouting"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0"),
  ],
  targets: [
    // Macro implementation (compiler plugin)
    .macro(
      name: "DeepLinkMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),

    // Runtime library that clients import
    .target(
      name: "DeepLinkRouting",
      dependencies: ["DeepLinkMacros"]
    ),

    // Macro tests
    .testTarget(
      name: "DeepLinkMacrosTests",
      dependencies: [
        "DeepLinkMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),

    // Runtime tests
    .testTarget(
      name: "DeepLinkRoutingTests",
      dependencies: ["DeepLinkRouting"]
    ),
  ]
)
