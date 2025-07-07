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
      let baseType: String
      if let optionalType = param.type.as(OptionalTypeSyntax.self) {
        baseType = optionalType.wrappedType.trimmedDescription
      } else {
        baseType = typeString.replacingOccurrences(of: "?", with: "")
      }

      return CaseInfo.CaseParameter(
        name: paramName,
        type: baseType,
        isOptional: isOptional,
        hasDefault: hasDefault
      )
    }

    return CaseInfo(name: caseName, parameters: parameters)
  }
}
