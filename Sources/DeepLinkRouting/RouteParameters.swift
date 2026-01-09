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

  // MARK: - Array Access (Query Parameters Only)

  /// Gets an array of Ints from a comma-separated query parameter.
  /// Returns nil if the parameter is missing or empty.
  public func queryInts(_ name: String) -> [Int]? {
    guard let value = queryParams[name], !value.isEmpty else { return nil }
    let result = value.split(separator: ",")
      .compactMap { Int(String($0).trimmingCharacters(in: .whitespaces)) }
    return result.isEmpty ? nil : result
  }

  /// Gets an array of Strings from a comma-separated query parameter.
  /// Returns nil if the parameter is missing or empty.
  public func queryStrings(_ name: String) -> [String]? {
    guard let value = queryParams[name], !value.isEmpty else { return nil }
    let result = value.split(separator: ",")
      .map { String($0).trimmingCharacters(in: .whitespaces) }
      .filter { !$0.isEmpty }
    return result.isEmpty ? nil : result
  }

  /// Gets an array of Doubles from a comma-separated query parameter.
  /// Returns nil if the parameter is missing or empty.
  public func queryDoubles(_ name: String) -> [Double]? {
    guard let value = queryParams[name], !value.isEmpty else { return nil }
    let result = value.split(separator: ",")
      .compactMap { Double(String($0).trimmingCharacters(in: .whitespaces)) }
    return result.isEmpty ? nil : result
  }

  /// Gets an array of Bools from a comma-separated query parameter.
  /// Returns nil if the parameter is missing or empty.
  /// Recognizes: true/false, 1/0, yes/no (case-insensitive)
  public func queryBools(_ name: String) -> [Bool]? {
    guard let value = queryParams[name], !value.isEmpty else { return nil }
    let result = value.split(separator: ",")
      .compactMap { element -> Bool? in
        switch String(element).trimmingCharacters(in: .whitespaces).lowercased() {
        case "true", "1", "yes": return true
        case "false", "0", "no": return false
        default: return nil
        }
      }
    return result.isEmpty ? nil : result
  }

  // MARK: - RawRepresentable Enum Access

  /// Gets a RawRepresentable enum with String raw value from a query parameter.
  /// Returns nil if the parameter is missing or the raw value doesn't match any case.
  public func queryEnum<E: RawRepresentable>(_ name: String) -> E? where E.RawValue == String {
    queryParams[name].flatMap { E(rawValue: $0) }
  }

  /// Gets a RawRepresentable enum with Int raw value from a query parameter.
  /// Returns nil if the parameter is missing, not a valid integer, or doesn't match any case.
  public func queryEnum<E: RawRepresentable>(_ name: String) -> E? where E.RawValue == Int {
    queryParams[name].flatMap { Int($0) }.flatMap { E(rawValue: $0) }
  }

  /// Gets a RawRepresentable enum with String raw value from a path parameter.
  /// Returns nil if the parameter is missing or the raw value doesn't match any case.
  public func pathEnum<E: RawRepresentable>(_ name: String) -> E? where E.RawValue == String {
    pathParams[name].flatMap { E(rawValue: $0) }
  }

  /// Gets a RawRepresentable enum with Int raw value from a path parameter.
  /// Returns nil if the parameter is missing, not a valid integer, or doesn't match any case.
  public func pathEnum<E: RawRepresentable>(_ name: String) -> E? where E.RawValue == Int {
    pathParams[name].flatMap { Int($0) }.flatMap { E(rawValue: $0) }
  }
}
