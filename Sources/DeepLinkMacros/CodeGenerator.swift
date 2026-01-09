//
//  CodeGenerator.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

struct CodeGenerator {

  static func generate(
    caseName: String,
    pattern: String,
    segments: [ParsedPattern.Segment],
    queryParams: [String],
    caseParams: [CaseInfo.CaseParameter]
  ) -> String {

    let segmentsCode = generateSegmentsArray(segments)
    let queryParamsCode = generateQueryParamsArray(queryParams)
    let buildClosure = generateBuildClosure(
      caseName: caseName,
      segments: segments,
      queryParams: queryParams,
      caseParams: caseParams
    )

    return """
    static let __route_\(caseName) = DeepLinkRouteDefinition<Self>(
      pattern: "\(pattern)",
      segments: \(segmentsCode),
      queryParams: \(queryParamsCode),
      build: \(buildClosure)
    )
    """
  }

  private static func generateSegmentsArray(_ segments: [ParsedPattern.Segment]) -> String {
    let elements = segments.map { segment -> String in
      switch segment {
      case .literal(let value):
        return ".literal(\"\(value)\")"
      case .parameter(let name):
        return ".parameter(\"\(name)\")"
      case .wildcard:
        return ".wildcard"
      }
    }
    return "[\(elements.joined(separator: ", "))]"
  }

  private static func generateQueryParamsArray(_ params: [String]) -> String {
    if params.isEmpty { return "[]" }
    let elements = params.map { "\"\($0)\"" }
    return "[\(elements.joined(separator: ", "))]"
  }

  private static func generateBuildClosure(
    caseName: String,
    segments: [ParsedPattern.Segment],
    queryParams: [String],
    caseParams: [CaseInfo.CaseParameter]
  ) -> String {

    // No parameters case
    if caseParams.isEmpty {
      return "{ _ in .\(caseName) }"
    }

    // Extract path parameter names from pattern (in order)
    let pathParamNames = segments.compactMap { segment -> String? in
      if case .parameter(let name) = segment { return name }
      return nil
    }

    // Build a set of query param names for fast lookup
    let queryParamSet = Set(queryParams)

    // Track which path params have been used (for positional fallback)
    var usedPathParamIndices = Set<Int>()

    // Generate parameter extraction code
    var extractionLines: [String] = []
    var caseArguments: [String] = []

    for param in caseParams {
      let paramName = param.name

      // Determine the source of this parameter:
      // 1. Check if param name matches a path parameter name (name-based matching)
      // 2. Check if param name is in query params
      // 3. Check if param has a default value (skip extraction)
      // 4. Check if param is optional (use nil)
      // 5. Otherwise, try positional path param matching as fallback

      var accessor: String? = nil

      // Try name-based path param matching first
      if let pathIndex = pathParamNames.firstIndex(of: paramName) {
        usedPathParamIndices.insert(pathIndex)
        accessor = generatePathAccessor(
          urlParamName: paramName,
          param: param
        )
      }
      // Check query params by name
      else if queryParamSet.contains(paramName) {
        accessor = generateQueryAccessor(
          urlParamName: paramName,
          param: param
        )
      }
      // Parameter has default value - skip extraction, let Swift use default
      else if param.hasDefault {
        continue
      }
      // Optional parameter not in URL - use nil
      else if param.isOptional {
        accessor = "nil"
      }
      // Fallback: try positional matching for remaining path params
      else {
        // Find first unused path param
        for (index, pathParamName) in pathParamNames.enumerated() {
          if !usedPathParamIndices.contains(index) {
            usedPathParamIndices.insert(index)
            accessor = generatePathAccessor(
              urlParamName: pathParamName,
              param: param
            )
            break
          }
        }
      }

      // If we still have no accessor, this is an error case
      guard let finalAccessor = accessor else {
        // Required parameter with no source - route will never match
        extractionLines.append("let \(paramName): \(param.type)? = nil")
        extractionLines.append("guard let \(paramName) = \(paramName) else { return nil }")
        caseArguments.append("\(paramName): \(paramName)")
        continue
      }

      // Determine if we need a guard (required non-optional, non-array, non-enum-with-default)
      let needsGuard = !param.isOptional && !param.hasDefault && !param.isArray && accessor != "nil"

      if needsGuard && param.isEnumType {
        // For required enums, we need guard but the accessor returns optional
        extractionLines.append("guard let \(paramName): \(param.type) = \(finalAccessor) else { return nil }")
      } else if needsGuard {
        extractionLines.append("guard let \(paramName) = \(finalAccessor) else { return nil }")
      } else {
        extractionLines.append("let \(paramName) = \(finalAccessor)")
      }

      caseArguments.append("\(paramName): \(paramName)")
    }

    let extractionCode = extractionLines.joined(separator: "\n      ")
    let argumentsCode = caseArguments.joined(separator: ", ")

    return """
    { params in
          \(extractionCode)
          return .\(caseName)(\(argumentsCode))
        }
    """
  }

  private static func generatePathAccessor(urlParamName: String, param: CaseInfo.CaseParameter) -> String {
    // Handle enum types (RawRepresentable)
    if param.isEnumType {
      return "params.pathEnum(\"\(urlParamName)\")"
    }

    // Handle scalar types
    switch param.type {
    case "Int":
      return "params.pathInt(\"\(urlParamName)\")"
    case "Bool":
      return "params.path(\"\(urlParamName)\").flatMap { $0 == \"true\" || $0 == \"1\" }"
    default:
      return "params.path(\"\(urlParamName)\")"
    }
  }

  private static func generateQueryAccessor(urlParamName: String, param: CaseInfo.CaseParameter) -> String {
    // Handle array types
    if param.isArray, let element = param.elementType {
      switch element {
      case "Int":
        return param.isOptional
          ? "params.queryInts(\"\(urlParamName)\")"
          : "(params.queryInts(\"\(urlParamName)\") ?? [])"
      case "String":
        return param.isOptional
          ? "params.queryStrings(\"\(urlParamName)\")"
          : "(params.queryStrings(\"\(urlParamName)\") ?? [])"
      case "Double":
        return param.isOptional
          ? "params.queryDoubles(\"\(urlParamName)\")"
          : "(params.queryDoubles(\"\(urlParamName)\") ?? [])"
      case "Bool":
        return param.isOptional
          ? "params.queryBools(\"\(urlParamName)\")"
          : "(params.queryBools(\"\(urlParamName)\") ?? [])"
      default:
        // Unsupported array element type - will be caught by validation
        return "params.queryStrings(\"\(urlParamName)\")"
      }
    }

    // Handle enum types (RawRepresentable)
    if param.isEnumType {
      return "params.queryEnum(\"\(urlParamName)\")"
    }

    // Handle scalar types
    switch param.type {
    case "Int":
      return "params.queryInt(\"\(urlParamName)\")"
    case "Bool":
      return "params.queryBool(\"\(urlParamName)\")"
    default:
      return "params.query(\"\(urlParamName)\")"
    }
  }
}
