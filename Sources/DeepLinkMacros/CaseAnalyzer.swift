//
//  CaseAnalyzer.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftSyntax

struct CaseInfo {
  let name: String
  let parameters: [CaseParameter]

  struct CaseParameter {
    let name: String
    let type: String
    let isOptional: Bool
    let hasDefault: Bool
    let isArray: Bool
    let elementType: String?  // For arrays, the element type (e.g., "Int" for [Int])
    let isScalarType: Bool    // True for String, Int, Bool, Double
    let isEnumType: Bool      // True for unknown types (assumed RawRepresentable)
  }
}

struct CaseAnalyzer {

  static func analyze(_ caseElement: EnumCaseElementSyntax) throws -> CaseInfo {
    let caseName = caseElement.name.text

    guard let parameterClause = caseElement.parameterClause else {
      // Case has no parameters
      return CaseInfo(name: caseName, parameters: [])
    }

    let parameters = parameterClause.parameters.map { param -> CaseInfo.CaseParameter in
      let paramName = param.firstName?.text ?? "_"
      let typeString = param.type.trimmedDescription
      let isOptional = typeString.hasSuffix("?") || param.type.is(OptionalTypeSyntax.self)
      let hasDefault = param.defaultValue != nil

      // Extract base type (remove Optional wrapper)
      var baseType: String
      if let optionalType = param.type.as(OptionalTypeSyntax.self) {
        baseType = optionalType.wrappedType.trimmedDescription
      } else {
        baseType = typeString.replacingOccurrences(of: "?", with: "")
      }

      // Detect array types: [Element] or Array<Element>
      let (isArray, elementType) = detectArrayType(baseType)
      if isArray, let element = elementType {
        baseType = "[\(element)]"
      }

      // Detect if this is a known scalar type or an unknown (enum) type
      let scalarTypes = ["String", "Int", "Bool", "Double"]
      let isScalarType = scalarTypes.contains(baseType)
      let isEnumType = !isScalarType && !isArray

      return CaseInfo.CaseParameter(
        name: paramName,
        type: baseType,
        isOptional: isOptional,
        hasDefault: hasDefault,
        isArray: isArray,
        elementType: elementType,
        isScalarType: isScalarType,
        isEnumType: isEnumType
      )
    }

    return CaseInfo(name: caseName, parameters: parameters)
  }

  /// Detects if a type string represents an array and extracts the element type.
  /// Supports `[Element]` and `Array<Element>` syntax.
  private static func detectArrayType(_ typeString: String) -> (isArray: Bool, elementType: String?) {
    let trimmed = typeString.trimmingCharacters(in: .whitespaces)

    // Check for [Element] syntax
    if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
      let element = String(trimmed.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
      if !element.isEmpty {
        return (true, element)
      }
    }

    // Check for Array<Element> syntax
    if trimmed.hasPrefix("Array<") && trimmed.hasSuffix(">") {
      let element = String(trimmed.dropFirst(6).dropLast()).trimmingCharacters(in: .whitespaces)
      if !element.isEmpty {
        return (true, element)
      }
    }

    return (false, nil)
  }
}
