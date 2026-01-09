//
//  DiagnosticMessages.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

enum DiagnosticError: Error, CustomStringConvertible {
  case notAnEnumCase
  case destinationMustBeEnum
  case missingPattern
  case patternMustBeStringLiteral
  case patternMustStartWithSlash(String)
  case emptyPathSegment(String)
  case emptyParameterName(String)
  case invalidParameterName(String, in: String)
  case multipleWildcards(String)
  case queryMustBeStringArray
  case parameterCountMismatch(pattern: Int, case: Int)
  case unsupportedParameterType(String)
  case arrayInPathParameter(String)
  case unsupportedArrayElementType(String)

  var description: String {
    switch self {
    case .notAnEnumCase:
      return "@DeepLinkRoute can only be applied to enum cases"
    case .destinationMustBeEnum:
      return "@DeepLinkDestination can only be applied to enums"
    case .missingPattern:
      return "@DeepLinkRoute requires a URL pattern string"
    case .patternMustBeStringLiteral:
      return "URL pattern must be a string literal"
    case .patternMustStartWithSlash(let pattern):
      return "URL pattern must start with '/': \(pattern)"
    case .emptyPathSegment(let pattern):
      return "URL pattern contains empty segment (double slash): \(pattern)"
    case .emptyParameterName(let pattern):
      return "URL pattern contains empty parameter name: \(pattern)"
    case .invalidParameterName(let name, let pattern):
      return "Invalid parameter name '\(name)' in pattern: \(pattern)"
    case .multipleWildcards(let pattern):
      return "URL pattern can only contain one wildcard (**): \(pattern)"
    case .queryMustBeStringArray:
      return "query parameter must be an array of strings"
    case .parameterCountMismatch(let pattern, let caseCount):
      return "Pattern has \(pattern) parameters but case has \(caseCount) required parameters"
    case .unsupportedParameterType(let type):
      return "Unsupported parameter type '\(type)'. Supported types: String, Int, Bool, [String], [Int], [Double], [Bool]"
    case .arrayInPathParameter(let name):
      return "Array parameter '\(name)' cannot be used in URL path. Arrays are only supported as query parameters."
    case .unsupportedArrayElementType(let type):
      return "Unsupported array element type '\(type)'. Supported array element types: String, Int, Double, Bool"
    }
  }
}
