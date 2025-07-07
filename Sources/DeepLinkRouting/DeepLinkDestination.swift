//
//  DeepLinkDestination.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Marks an enum as a deep link destination and generates route collection.
///
/// This macro scans all enum cases with @DeepLinkRoute and generates:
/// 1. DeepLinkRoutable protocol conformance
/// 2. `allRoutes` static property collecting all routes
///
/// ## Usage
/// ```swift
/// @DeepLinkDestination
/// enum MyDestination {
///   @DeepLinkRoute("/users/:id")
///   case userProfile(userId: Int)
///
///   @DeepLinkRoute("/settings")
///   case settings
///
///   case other  // Not deep-linkable (no route annotation)
/// }
///
/// // Generated:
/// extension MyDestination: DeepLinkRoutable {
///   static var allRoutes: [DeepLinkRouteDefinition<MyDestination>] {
///     [__route_userProfile, __route_settings]
///   }
/// }
/// ```
@attached(extension, conformances: DeepLinkRoutable, names: named(allRoutes))
public macro DeepLinkDestination() = #externalMacro(module: "DeepLinkMacros", type: "DeepLinkDestinationMacro")
