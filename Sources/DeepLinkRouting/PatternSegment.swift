//
//  PatternSegment.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A segment in a URL pattern.
public enum PatternSegment: Sendable, Equatable, Hashable {
  /// Literal path segment that must match exactly (case-insensitive)
  case literal(String)

  /// Parameter segment that captures the value
  case parameter(String)

  /// Wildcard that matches any number of segments
  case wildcard
}

extension PatternSegment {
  /// Parses a pattern string into segments.
  public static func parse(_ pattern: String) -> [PatternSegment] {
    guard pattern.hasPrefix("/") else { return [] }

    // Handle root path
    if pattern == "/" {
      return []
    }

    return pattern
      .dropFirst() // Remove leading /
      .split(separator: "/", omittingEmptySubsequences: false)
      .compactMap { segment -> PatternSegment? in
        let s = String(segment)
        if s.isEmpty { return nil }
        if s == "**" { return .wildcard }
        if s.hasPrefix(":") { return .parameter(String(s.dropFirst())) }
        return .literal(s)
      }
  }
}
