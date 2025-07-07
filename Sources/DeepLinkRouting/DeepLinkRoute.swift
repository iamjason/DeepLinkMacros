//
//  DeepLinkRoute.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Declares a URL route pattern for an enum case.
///
/// The macro generates a static route definition that can be used for URL matching.
///
/// ## Usage
/// ```swift
/// @DeepLinkDestination
/// enum Destination {
///   @DeepLinkRoute("/users/:id")
///   case userProfile(userId: Int)
/// }
/// ```
///
/// ## Pattern Syntax
/// - `/literal` - Matches exact path segment
/// - `/:param` - Captures path segment as named parameter
/// - `/**` - Wildcard, matches any number of segments
///
/// ## Parameter Mapping
/// - Path parameters (`:name`) map to case parameters by position or name
/// - Query parameters are extracted from the URL query string
/// - Types are automatically converted (String, Int, Bool supported)
///
@attached(peer, names: prefixed(__route_))
public macro DeepLinkRoute(
  _ pattern: String,
  query: [String] = []
) = #externalMacro(module: "DeepLinkMacros", type: "DeepLinkRouteMacro")
