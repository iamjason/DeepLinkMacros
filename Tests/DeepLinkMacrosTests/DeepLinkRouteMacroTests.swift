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

  // MARK: - Array Parameter Tests

  func testRouteWithOptionalIntArray() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum SearchDestination {
        @DeepLinkRoute("/search", query: ["ids"])
        case searchWithIds(ids: [Int]?)
      }
      """,
      expandedSource: """
      enum SearchDestination {
        case searchWithIds(ids: [Int]?)

        static let __route_searchWithIds = DeepLinkRouteDefinition<Self>(
          pattern: "/search",
          segments: [.literal("search")],
          queryParams: ["ids"],
          build: { params in
              let ids = params.queryInts("ids")
              return .searchWithIds(ids: ids)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testRouteWithOptionalStringArray() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum FilterDestination {
        @DeepLinkRoute("/filter", query: ["tags"])
        case filterWithTags(tags: [String]?)
      }
      """,
      expandedSource: """
      enum FilterDestination {
        case filterWithTags(tags: [String]?)

        static let __route_filterWithTags = DeepLinkRouteDefinition<Self>(
          pattern: "/filter",
          segments: [.literal("filter")],
          queryParams: ["tags"],
          build: { params in
              let tags = params.queryStrings("tags")
              return .filterWithTags(tags: tags)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testRouteWithRequiredIntArray() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum RequiredDestination {
        @DeepLinkRoute("/required", query: ["values"])
        case requiredArray(values: [Int])
      }
      """,
      expandedSource: """
      enum RequiredDestination {
        case requiredArray(values: [Int])

        static let __route_requiredArray = DeepLinkRouteDefinition<Self>(
          pattern: "/required",
          segments: [.literal("required")],
          queryParams: ["values"],
          build: { params in
              let values = (params.queryInts("values") ?? [])
              return .requiredArray(values: values)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testRouteWithMixedScalarAndArray() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum MixedDestination {
        @DeepLinkRoute("/mixed", query: ["name", "ids"])
        case mixedParams(name: String?, ids: [Int]?)
      }
      """,
      expandedSource: """
      enum MixedDestination {
        case mixedParams(name: String?, ids: [Int]?)

        static let __route_mixedParams = DeepLinkRouteDefinition<Self>(
          pattern: "/mixed",
          segments: [.literal("mixed")],
          queryParams: ["name", "ids"],
          build: { params in
              let name = params.query("name")
              let ids = params.queryInts("ids")
              return .mixedParams(name: name, ids: ids)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testRouteWithDoubleArray() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum PriceDestination {
        @DeepLinkRoute("/prices", query: ["values"])
        case priceFilter(values: [Double]?)
      }
      """,
      expandedSource: """
      enum PriceDestination {
        case priceFilter(values: [Double]?)

        static let __route_priceFilter = DeepLinkRouteDefinition<Self>(
          pattern: "/prices",
          segments: [.literal("prices")],
          queryParams: ["values"],
          build: { params in
              let values = params.queryDoubles("values")
              return .priceFilter(values: values)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }

  func testRouteWithBoolArray() throws {
    #if canImport(DeepLinkMacros)
    assertMacroExpansion(
      """
      enum FlagDestination {
        @DeepLinkRoute("/flags", query: ["enabled"])
        case flagFilter(enabled: [Bool]?)
      }
      """,
      expandedSource: """
      enum FlagDestination {
        case flagFilter(enabled: [Bool]?)

        static let __route_flagFilter = DeepLinkRouteDefinition<Self>(
          pattern: "/flags",
          segments: [.literal("flags")],
          queryParams: ["enabled"],
          build: { params in
              let enabled = params.queryBools("enabled")
              return .flagFilter(enabled: enabled)
            }
        )
      }
      """,
      macros: testMacros
    )
    #endif
  }
}
