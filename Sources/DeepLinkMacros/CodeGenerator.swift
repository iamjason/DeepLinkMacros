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

    // Extract path parameter names from pattern
    let pathParamNames = segments.compactMap { segment -> String? in
      if case .parameter(let name) = segment { return name }
      return nil
    }

    // Generate parameter extraction code
    var extractionLines: [String] = []
    var caseArguments: [String] = []

    for (index, param) in caseParams.enumerated() {
      let paramName = param.name

      // Determine if this is a path or query parameter
      let isPathParam = index < pathParamNames.count
      let urlParamName = isPathParam ? pathParamNames[index] : paramName

      let accessor: String
      if isPathParam {
        accessor = generatePathAccessor(urlParamName: urlParamName, type: param.type, isOptional: param.isOptional)
      } else if queryParams.contains(paramName) || queryParams.contains(urlParamName) {
        accessor = generateQueryAccessor(
          urlParamName: urlParamName,
          type: param.type,
          isOptional: param.isOptional,
          isArray: param.isArray,
          elementType: param.elementType
        )
      } else if param.hasDefault {
        // Parameter has default value, skip extraction
        continue
      } else {
        // Required parameter not in pattern or query - use nil accessor
        accessor = "nil"
      }

      // Non-optional arrays use ?? [] in accessor, so don't need guard
      let needsGuard = !param.isOptional && !param.hasDefault && !param.isArray
      if needsGuard {
        extractionLines.append("guard let \(paramName) = \(accessor) else { return nil }")
      } else {
        extractionLines.append("let \(paramName) = \(accessor)")
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

  private static func generatePathAccessor(urlParamName: String, type: String, isOptional: Bool) -> String {
    switch type {
    case "Int":
      return "params.pathInt(\"\(urlParamName)\")"
    case "Bool":
      return "params.path(\"\(urlParamName)\").flatMap { $0 == \"true\" || $0 == \"1\" }"
    default:
      return "params.path(\"\(urlParamName)\")"
    }
  }

  private static func generateQueryAccessor(urlParamName: String, type: String, isOptional: Bool, isArray: Bool, elementType: String?) -> String {
    // Handle array types
    if isArray, let element = elementType {
      switch element {
      case "Int":
        return isOptional
          ? "params.queryInts(\"\(urlParamName)\")"
          : "(params.queryInts(\"\(urlParamName)\") ?? [])"
      case "String":
        return isOptional
          ? "params.queryStrings(\"\(urlParamName)\")"
          : "(params.queryStrings(\"\(urlParamName)\") ?? [])"
      case "Double":
        return isOptional
          ? "params.queryDoubles(\"\(urlParamName)\")"
          : "(params.queryDoubles(\"\(urlParamName)\") ?? [])"
      case "Bool":
        return isOptional
          ? "params.queryBools(\"\(urlParamName)\")"
          : "(params.queryBools(\"\(urlParamName)\") ?? [])"
      default:
        // Unsupported array element type - will be caught by validation
        return "params.queryStrings(\"\(urlParamName)\")"
      }
    }

    // Handle scalar types
    switch type {
    case "Int":
      return "params.queryInt(\"\(urlParamName)\")"
    case "Bool":
      return "params.queryBool(\"\(urlParamName)\")"
    default:
      return "params.query(\"\(urlParamName)\")"
    }
  }
}
