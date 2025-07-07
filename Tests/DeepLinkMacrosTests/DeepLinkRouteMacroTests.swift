//
//  DeepLinkRouteMacroTests.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(DeepLinkMacros)
import DeepLinkMacros

let testMacros: [String: Macro.Type] = [
  "DeepLinkRoute": DeepLinkRouteMacro.self,
  "DeepLinkDestination": DeepLinkDestinationMacro.self,
]
#endif

final class DeepLinkRouteMacroTests: XCTestCase {

  func testSimpleRoute() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum BobsBurgersDestination {
        @DeepLinkRoute("/restaurant")
        case restaurant
      }
      """,
      expandedSource: """
      enum BobsBurgersDestination {
        case restaurant

        static let __route_restaurant = DeepLinkRouteDefinition<Self>(
          pattern: "/restaurant",
          segments: [.literal("restaurant")],
          queryParams: [],
          build: { _ in
              .restaurant
          }
        )
      }
      """,
      macros: testMacros
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testRouteWithPathParameter() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum BobsBurgersDestination {
        @DeepLinkRoute("/employees/:id")
        case employee(employeeId: Int)
      }
      """,
      expandedSource: """
      enum BobsBurgersDestination {
        case employee(employeeId: Int)

        static let __route_employee = DeepLinkRouteDefinition<Self>(
          pattern: "/employees/:id",
          segments: [.literal("employees"), .parameter("id")],
          queryParams: [],
          build: { params in
              guard let employeeId = params.pathInt("id") else {
                  return nil
              }
              return .employee(employeeId: employeeId)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testRouteWithQueryParameters() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum BobsBurgersDestination {
        @DeepLinkRoute("/menu", query: ["q", "page"])
        case menuSearch(q: String?, page: Int?)
      }
      """,
      expandedSource: """
      enum BobsBurgersDestination {
        case menuSearch(q: String?, page: Int?)

        static let __route_menuSearch = DeepLinkRouteDefinition<Self>(
          pattern: "/menu",
          segments: [.literal("menu")],
          queryParams: ["q", "page"],
          build: { params in
              let q = params.query("q")
              let page = params.queryInt("page")
              return .menuSearch(q: q, page: page)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testRouteWithWildcard() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum BobsBurgersDestination {
        @DeepLinkRoute("/episodes/**/:slug")
        case episode(slug: String)
      }
      """,
      expandedSource: """
      enum BobsBurgersDestination {
        case episode(slug: String)

        static let __route_episode = DeepLinkRouteDefinition<Self>(
          pattern: "/episodes/**/:slug",
          segments: [.literal("episodes"), .wildcard, .parameter("slug")],
          queryParams: [],
          build: { params in
              guard let slug = params.path("slug") else {
                  return nil
              }
              return .episode(slug: slug)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testDeepLinkDestinationMacro() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      @DeepLinkDestination
      enum BobsBurgersDestination {
        @DeepLinkRoute("/restaurant")
        case restaurant

        @DeepLinkRoute("/kitchen")
        case kitchen

        case wonderWharf
      }
      """,
      expandedSource: """
      enum BobsBurgersDestination {
        case restaurant

        static let __route_restaurant = DeepLinkRouteDefinition<Self>(
          pattern: "/restaurant",
          segments: [.literal("restaurant")],
          queryParams: [],
          build: { _ in
              .restaurant
          }
        )
        case kitchen

        static let __route_kitchen = DeepLinkRouteDefinition<Self>(
          pattern: "/kitchen",
          segments: [.literal("kitchen")],
          queryParams: [],
          build: { _ in
              .kitchen
          }
        )

        case wonderWharf
      }

      extension BobsBurgersDestination: DeepLinkRoutable {
        public static var allRoutes: [DeepLinkRouteDefinition<BobsBurgersDestination>] {
          [__route_restaurant, __route_kitchen]
        }
      }
      """,
      macros: testMacros
    )
    #endif
  }
}
