//
//  MacroArguments.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftSyntax

struct MacroArguments {
  let pattern: String
  let queryParams: [String]

  static func parse(from node: AttributeSyntax) throws -> MacroArguments {
    guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
      throw DiagnosticError.missingPattern
    }

    var pattern: String?
    var queryParams: [String] = []

    for argument in arguments {
      if argument.label == nil || argument.label?.text == "pattern" {
        // First unlabeled argument or "pattern:" is the URL pattern
        guard let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
              let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) else {
          throw DiagnosticError.patternMustBeStringLiteral
        }
        pattern = segment.content.text
      } else if argument.label?.text == "query" {
        // "query:" argument is array of query param names
        guard let arrayExpr = argument.expression.as(ArrayExprSyntax.self) else {
          throw DiagnosticError.queryMustBeStringArray
        }
        queryParams = arrayExpr.elements.compactMap { element in
          element.expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.as(StringSegmentSyntax.self)?.content.text
        }
      }
    }

    guard let patternValue = pattern else {
      throw DiagnosticError.missingPattern
    }

    return MacroArguments(pattern: patternValue, queryParams: queryParams)
  }
}
