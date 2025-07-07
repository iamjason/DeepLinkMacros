//
//  RouteParameters.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Parameters extracted from a URL for route matching.
public struct RouteParameters: Sendable {
  private let pathParams: [String: String]
  private let queryParams: [String: String]

  public init(path: [String: String] = [:], query: [String: String] = [:]) {
    self.pathParams = path
    self.queryParams = query
  }

  // MARK: - String Access

  /// Gets a required string parameter from path.
  public func path(_ name: String) -> String? {
    pathParams[name]
  }

  /// Gets an optional string parameter from query.
  public func query(_ name: String) -> String? {
    queryParams[name]
  }

  // MARK: - Int Access

  /// Gets a required Int parameter from path.
  public func pathInt(_ name: String) -> Int? {
    pathParams[name].flatMap(Int.init)
  }

  /// Gets an optional Int parameter from query.
  public func queryInt(_ name: String) -> Int? {
    queryParams[name].flatMap(Int.init)
  }

  // MARK: - Bool Access

  /// Gets a Bool parameter from query.
  public func queryBool(_ name: String) -> Bool? {
    guard let value = queryParams[name] else { return nil }
    switch value.lowercased() {
    case "true", "1", "yes": return true
    case "false", "0", "no": return false
    default: return nil
    }
  }

  // MARK: - Subscript Access

  /// Gets any parameter (path or query) as String.
  public subscript(_ name: String) -> String? {
    pathParams[name] ?? queryParams[name]
  }
}
