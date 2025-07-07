//
//  DeepLinkRouter.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A router that matches URL strings to destination enum cases.
///
/// ## Usage
/// ```swift
/// let router = DeepLinkRouter<MyDestination>()
///
/// if let destination = router.match("/users/42") {
///   navigate(to: destination)
/// }
/// ```
public final class DeepLinkRouter<Destination: DeepLinkRoutable>: Sendable {

  /// All registered routes for this destination type.
  public let routes: [DeepLinkRouteDefinition<Destination>]

  /// Creates a router that auto-discovers routes from the Destination type.
  public init() {
    self.routes = Destination.allRoutes
  }

  /// Creates a router with explicit routes (useful for testing or custom routing).
  public init(routes: [DeepLinkRouteDefinition<Destination>]) {
    self.routes = routes
  }

  // MARK: - Matching

  /// Matches a URL string to a destination.
  ///
  /// - Parameter urlString: The URL path to match (e.g., "/users/42?tab=profile")
  /// - Returns: The matched destination, or nil if no route matches.
  public func match(_ urlString: String) -> Destination? {
    match(URL(string: urlString))
  }

  /// Matches a URL to a destination.
  ///
  /// - Parameter url: The URL to match
  /// - Returns: The matched destination, or nil if no route matches.
  public func match(_ url: URL?) -> Destination? {
    guard let url = url else { return nil }

    let pathSegments = url.pathSegments
    let queryItems = url.queryDictionary

    for route in routes {
      if let params = PatternMatcher.match(
        pathSegments: pathSegments,
        queryItems: queryItems,
        against: route.segments,
        extractingQuery: route.queryParams
      ) {
        if let destination = route.build(params) {
          return destination
        }
      }
    }

    return nil
  }

  /// Matches a URL and returns detailed result including the matched route.
  ///
  /// - Parameter urlString: The URL path to match
  /// - Returns: Match result with destination and route info, or nil if no match.
  public func matchWithDetails(_ urlString: String) -> MatchResult? {
    guard let url = URL(string: urlString) else { return nil }

    let pathSegments = url.pathSegments
    let queryItems = url.queryDictionary

    for route in routes {
      if let params = PatternMatcher.match(
        pathSegments: pathSegments,
        queryItems: queryItems,
        against: route.segments,
        extractingQuery: route.queryParams
      ) {
        if let destination = route.build(params) {
          return MatchResult(
            destination: destination,
            pattern: route.pattern,
            sourceType: String(describing: Destination.self),
            parameters: params
          )
        }
      }
    }

    return nil
  }

  /// Result of a detailed route match.
  public struct MatchResult {
    /// The matched destination enum case.
    public let destination: Destination

    /// The pattern that matched (e.g., "/users/:id").
    public let pattern: String

    /// The child destination type name (e.g., "HomepageDestination") - useful for multi-enum routers.
    public let sourceType: String?

    /// The extracted parameters.
    public let parameters: RouteParameters
  }
}

// MARK: - URL Helpers

extension URL {
  /// Extracts path segments from the URL.
  var pathSegments: [String] {
    path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
  }

  /// Extracts query parameters as a dictionary.
  var queryDictionary: [String: String] {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
          let queryItems = components.queryItems else {
      return [:]
    }
    return Dictionary(
      queryItems.compactMap { item in
        item.value.map { (item.name, $0) }
      },
      uniquingKeysWith: { _, last in last }
    )
  }
}
