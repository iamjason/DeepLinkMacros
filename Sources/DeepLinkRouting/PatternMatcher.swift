//
//  PatternMatcher.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Matches URL path segments against a route pattern.
public enum PatternMatcher {

  /// Attempts to match path segments against a pattern.
  ///
  /// - Parameters:
  ///   - pathSegments: The URL path split into segments (e.g., ["users", "42"])
  ///   - queryItems: Query parameters from the URL
  ///   - pattern: The pattern segments to match against
  ///   - queryParams: Query parameter names to extract
  /// - Returns: Extracted parameters if match succeeds, nil otherwise.
  public static func match(
    pathSegments: [String],
    queryItems: [String: String],
    against pattern: [PatternSegment],
    extractingQuery queryParams: [String]
  ) -> RouteParameters? {

    var pathParams: [String: String] = [:]
    var pathIndex = 0
    var patternIndex = 0

    while patternIndex < pattern.count {
      let segment = pattern[patternIndex]

      switch segment {
      case .literal(let expected):
        // Must match exactly (case-insensitive)
        guard pathIndex < pathSegments.count,
              pathSegments[pathIndex].lowercased() == expected.lowercased() else {
          return nil
        }
        pathIndex += 1
        patternIndex += 1

      case .parameter(let name):
        // Capture the path segment
        guard pathIndex < pathSegments.count else {
          return nil
        }
        pathParams[name] = pathSegments[pathIndex]
        pathIndex += 1
        patternIndex += 1

      case .wildcard:
        // Wildcard matches any number of segments
        patternIndex += 1

        // If wildcard is at the end, consume all remaining
        if patternIndex >= pattern.count {
          pathIndex = pathSegments.count
          break
        }

        // Count remaining pattern segments after wildcard
        let remainingPatternCount = pattern.count - patternIndex

        // Calculate how many path segments should be left for remaining patterns
        // The wildcard should consume all segments except what's needed for remaining patterns
        let targetPathIndex = pathSegments.count - remainingPatternCount

        // Ensure we don't go backwards
        if targetPathIndex >= pathIndex {
          pathIndex = targetPathIndex
        }
      }
    }

    // All pattern segments must be matched, and all path segments consumed
    guard pathIndex == pathSegments.count else {
      return nil
    }

    // Extract requested query parameters
    var extractedQuery: [String: String] = [:]
    for param in queryParams {
      if let value = queryItems[param] {
        extractedQuery[param] = value
      }
    }

    return RouteParameters(path: pathParams, query: extractedQuery)
  }

  /// Checks if a single path segment matches a pattern segment.
  private static func matchesSegment(_ path: String, pattern: PatternSegment) -> Bool {
    switch pattern {
    case .literal(let expected):
      return path.lowercased() == expected.lowercased()
    case .parameter:
      return true // Parameters match anything
    case .wildcard:
      return true // Wildcards match anything
    }
  }
}

// MARK: - Array Safe Subscript

extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}
