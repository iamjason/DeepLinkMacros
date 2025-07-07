//
//  PatternParser.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

struct ParsedPattern {
  let segments: [Segment]

  enum Segment {
    case literal(String)
    case parameter(String)
    case wildcard
  }
}

struct PatternParser {

  static func parse(_ pattern: String) throws -> [ParsedPattern.Segment] {
    // Validate pattern starts with /
    guard pattern.hasPrefix("/") else {
      throw DiagnosticError.patternMustStartWithSlash(pattern)
    }

    // Handle root path
    if pattern == "/" {
      return []
    }

    let pathPart = String(pattern.dropFirst())
    let components = pathPart.split(separator: "/", omittingEmptySubsequences: false)

    var segments: [ParsedPattern.Segment] = []
    var hasWildcard = false

    for component in components {
      let s = String(component)

      // Check for empty segment (double slash)
      if s.isEmpty {
        throw DiagnosticError.emptyPathSegment(pattern)
      }

      // Wildcard
      if s == "**" {
        if hasWildcard {
          throw DiagnosticError.multipleWildcards(pattern)
        }
        hasWildcard = true
        segments.append(.wildcard)
        continue
      }

      // Parameter
      if s.hasPrefix(":") {
        let paramName = String(s.dropFirst())
        if paramName.isEmpty {
          throw DiagnosticError.emptyParameterName(pattern)
        }
        if !paramName.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
          throw DiagnosticError.invalidParameterName(paramName, in: pattern)
        }
        segments.append(.parameter(paramName))
        continue
      }

      // Literal
      segments.append(.literal(s))
    }

    return segments
  }
}
