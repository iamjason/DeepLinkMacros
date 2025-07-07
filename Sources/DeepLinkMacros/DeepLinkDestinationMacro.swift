//
//  DeepLinkDestinationMacro.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DeepLinkDestinationMacro: ExtensionMacro {

  public static func expansion(
    of node: AttributeSyntax,
    attachedTo declaration: some DeclGroupSyntax,
    providingExtensionsOf type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    in context: some MacroExpansionContext
  ) throws -> [ExtensionDeclSyntax] {

    // 1. Validate this is attached to an enum
    guard declaration.is(EnumDeclSyntax.self) else {
      throw DiagnosticError.destinationMustBeEnum
    }

    // 2. Find all cases with @DeepLinkRoute attribute
    let routedCases = findRoutedCases(in: declaration)

    // 3. If no routed cases, generate empty allRoutes
    guard !routedCases.isEmpty else {
      let emptyExtension = try ExtensionDeclSyntax(
        """
        extension \(type.trimmed): DeepLinkRoutable {
          public static var allRoutes: [DeepLinkRouteDefinition<\(type.trimmed)>] { [] }
        }
        """
      )
      return [emptyExtension]
    }

    // 4. Generate allRoutes property with all route references
    let routeReferences = routedCases.map { "__route_\($0)" }.joined(separator: ", ")

    let extensionDecl = try ExtensionDeclSyntax(
      """
      extension \(type.trimmed): DeepLinkRoutable {
        public static var allRoutes: [DeepLinkRouteDefinition<\(type.trimmed)>] {
          [\(raw: routeReferences)]
        }
      }
      """
    )

    return [extensionDecl]
  }

  /// Finds all enum cases that have the @DeepLinkRoute attribute.
  private static func findRoutedCases(in declaration: some DeclGroupSyntax) -> [String] {
    var routedCases: [String] = []

    for member in declaration.memberBlock.members {
      guard let enumCaseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
        continue
      }

      // Check if this case has @DeepLinkRoute attribute
      let hasRouteAttribute = enumCaseDecl.attributes.contains { attr in
        guard let attributeSyntax = attr.as(AttributeSyntax.self),
              let identifier = attributeSyntax.attributeName.as(IdentifierTypeSyntax.self) else {
          return false
        }
        return identifier.name.text == "DeepLinkRoute"
      }

      if hasRouteAttribute {
        for element in enumCaseDecl.elements {
          routedCases.append(element.name.text)
        }
      }
    }

    return routedCases
  }
}
