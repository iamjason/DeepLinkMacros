//
//  UniversalDeepLinkRouter.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A router that aggregates multiple destination enums into a single wrapper type.
///
/// Use this when you have separate destination enums per tab (e.g., HomepageDestination,
/// BookingDestination) and want to match URLs against all of them, returning a unified
/// NavDestination wrapper.
///
/// ## Usage
/// ```swift
/// // Define your wrapper enum (no macro needed)
/// enum NavDestination {
///   case homepage(HomepageDestination)
///   case booking(BookingDestination)
///   case settings(SettingsDestination)
/// }
///
/// // Configure router using key paths - infers child type and wrapper automatically
/// let router = UniversalDeepLinkRouter<NavDestination>()
///   .include(HomepageDestination.self, as: NavDestination.homepage)
///   .include(BookingDestination.self, as: NavDestination.booking)
///   .include(SettingsDestination.self, as: NavDestination.settings)
///
/// // Match any URL - checks all enums in registration order
/// router.match("/courses/prenatal")  // -> .homepage(.course(slug: "prenatal"))
/// router.match("/book/123")          // -> .booking(.book(providerId: 123))
/// router.match("/care-team")         // -> .settings(.careTeam)
/// ```
public final class UniversalDeepLinkRouter<Wrapper>: @unchecked Sendable {

  /// Type-erased route matcher that can check any child destination type.
  private struct AnyRouteMatcher: @unchecked Sendable {
    let typeName: String
    let match: (URL) -> (destination: Wrapper, pattern: String, params: RouteParameters)?
  }

  private var matchers: [AnyRouteMatcher] = []

  public init() {}

  // MARK: - Registration

  /// Includes routes from a child destination type with explicit wrapper function.
  ///
  /// - Parameters:
  ///   - childType: The child destination enum type
  ///   - wrap: Function to wrap child destination in the wrapper type
  /// - Returns: Self for chaining
  @discardableResult
  public func include<Child: DeepLinkRoutable>(
    _ childType: Child.Type,
    as wrap: @escaping (Child) -> Wrapper
  ) -> Self {
    let childRouter = DeepLinkRouter<Child>()
    let typeName = String(describing: Child.self)

    let matcher = AnyRouteMatcher(typeName: typeName) { url in
      let pathSegments = url.pathSegments
      let queryItems = url.queryDictionary

      for route in childRouter.routes {
        if let params = PatternMatcher.match(
          pathSegments: pathSegments,
          queryItems: queryItems,
          against: route.segments,
          extractingQuery: route.queryParams
        ) {
          if let destination = route.build(params) {
            return (wrap(destination), route.pattern, params)
          }
        }
      }
      return nil
    }

    matchers.append(matcher)
    return self
  }

  // MARK: - Matching

  /// Matches a URL string against all registered destination types.
  ///
  /// Routes are checked in registration order (first registered = highest priority).
  ///
  /// - Parameter urlString: The URL to match
  /// - Returns: The wrapped destination, or nil if no route matches
  public func match(_ urlString: String) -> Wrapper? {
    guard let url = URL(string: urlString) else { return nil }
    return match(url)
  }

  /// Matches a URL against all registered destination types.
  public func match(_ url: URL) -> Wrapper? {
    for matcher in matchers {
      if let result = matcher.match(url) {
        return result.destination
      }
    }
    return nil
  }

  /// Matches a URL and returns detailed result including source type.
  public func matchWithDetails(_ urlString: String) -> MatchResult? {
    guard let url = URL(string: urlString) else { return nil }

    for matcher in matchers {
      if let result = matcher.match(url) {
        return MatchResult(
          destination: result.destination,
          pattern: result.pattern,
          sourceType: matcher.typeName,
          parameters: result.params
        )
      }
    }
    return nil
  }

  /// Result of a detailed route match.
  public struct MatchResult {
    /// The wrapped destination (e.g., NavDestination.homepage(...))
    public let destination: Wrapper

    /// The pattern that matched (e.g., "/courses/:slug")
    public let pattern: String

    /// The child destination type that matched (e.g., "HomepageDestination")
    public let sourceType: String

    /// The extracted parameters
    public let parameters: RouteParameters
  }

  // MARK: - Inspection

  /// Returns all registered destination type names, in priority order.
  public var registeredTypes: [String] {
    matchers.map(\.typeName)
  }

  /// Returns total route count across all registered destination types.
  public var totalRouteCount: Int {
    matchers.count
  }
}

// MARK: - Convenience Builder

extension UniversalDeepLinkRouter {

  /// Creates a router with multiple destination types using a builder closure.
  ///
  /// ```swift
  /// let router = UniversalDeepLinkRouter<NavDestination>.build {
  ///   $0.include(HomepageDestination.self, as: NavDestination.homepage)
  ///   $0.include(BookingDestination.self, as: NavDestination.booking)
  /// }
  /// ```
  public static func build(
    _ configure: (UniversalDeepLinkRouter) -> Void
  ) -> UniversalDeepLinkRouter {
    let router = UniversalDeepLinkRouter()
    configure(router)
    return router
  }
}
