//
//  DeepLinkRouteMacro.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DeepLinkRouteMacro: PeerMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {

    // 1. Validate this is attached to an enum case
    guard let enumCaseDecl = declaration.as(EnumCaseDeclSyntax.self),
          let caseElement = enumCaseDecl.elements.first else {
      throw DiagnosticError.notAnEnumCase
    }

    // 2. Extract macro arguments
    let arguments = try MacroArguments.parse(from: node)

    // 3. Parse the URL pattern
    let patternSegments = try PatternParser.parse(arguments.pattern)

    // 4. Analyze the enum case
    let caseInfo = try CaseAnalyzer.analyze(caseElement)

    // 5. Generate the route definition
    let generatedCode = CodeGenerator.generate(
      caseName: caseInfo.name,
      pattern: arguments.pattern,
      segments: patternSegments,
      queryParams: arguments.queryParams,
      caseParams: caseInfo.parameters
    )

    return [DeclSyntax(stringLiteral: generatedCode)]
  }
}
