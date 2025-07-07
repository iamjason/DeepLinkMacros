//
//  PatternMatchingTests.swift
//  DeepLinkMacros
//
//  Created by @iamjason on 7/6/25.
//  Copyright (c) 2025. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import DeepLinkRouting

final class PatternMatchingTests: XCTestCase {

  func testParseSimplePattern() {
    let segments = PatternSegment.parse("/burgers/list")
    XCTAssertEqual(segments, [.literal("burgers"), .literal("list")])
  }

  func testParsePatternWithParameter() {
    let segments = PatternSegment.parse("/employees/:id")
    XCTAssertEqual(segments, [.literal("employees"), .parameter("id")])
  }

  func testParsePatternWithWildcard() {
    let segments = PatternSegment.parse("/episodes/**/:slug")
    XCTAssertEqual(segments, [.literal("episodes"), .wildcard, .parameter("slug")])
  }

  func testParseRootPattern() {
    let segments = PatternSegment.parse("/")
    XCTAssertEqual(segments, [])
  }

  func testParseMultipleParameters() {
    let segments = PatternSegment.parse("/characters/:characterId/episodes/:episodeId")
    XCTAssertEqual(segments, [
      .literal("characters"),
      .parameter("characterId"),
      .literal("episodes"),
      .parameter("episodeId"),
    ])
  }

  func testRouteParametersPathAccess() {
    let params = RouteParameters(path: ["id": "1", "slug": "bet-it-all-on-black-garlic"], query: [:])

    XCTAssertEqual(params.path("id"), "1")
    XCTAssertEqual(params.pathInt("id"), 1)
    XCTAssertEqual(params.path("slug"), "bet-it-all-on-black-garlic")
    XCTAssertNil(params.path("missing"))
  }

  func testRouteParametersQueryAccess() {
    let params = RouteParameters(path: [:], query: ["page": "5", "showRecipe": "true"])

    XCTAssertEqual(params.query("page"), "5")
    XCTAssertEqual(params.queryInt("page"), 5)
    XCTAssertEqual(params.queryBool("showRecipe"), true)
    XCTAssertNil(params.query("missing"))
  }

  func testRouteParametersBoolConversion() {
    let params = RouteParameters(path: [:], query: [
      "a": "true",
      "b": "false",
      "c": "1",
      "d": "0",
      "e": "yes",
      "f": "no",
      "g": "invalid",
    ])

    XCTAssertEqual(params.queryBool("a"), true)
    XCTAssertEqual(params.queryBool("b"), false)
    XCTAssertEqual(params.queryBool("c"), true)
    XCTAssertEqual(params.queryBool("d"), false)
    XCTAssertEqual(params.queryBool("e"), true)
    XCTAssertEqual(params.queryBool("f"), false)
    XCTAssertNil(params.queryBool("g"))
  }

  func testPatternMatcherLiteralsOnly() {
    let result = PatternMatcher.match(
      pathSegments: ["burgers", "list"],
      queryItems: [:],
      against: [.literal("burgers"), .literal("list")],
      extractingQuery: []
    )

    XCTAssertNotNil(result)
  }

  func testPatternMatcherWithParameter() {
    let result = PatternMatcher.match(
      pathSegments: ["employees", "1"],
      queryItems: [:],
      against: [.literal("employees"), .parameter("id")],
      extractingQuery: []
    )

    XCTAssertNotNil(result)
    XCTAssertEqual(result?.path("id"), "1")
  }

  func testPatternMatcherWithWildcard() {
    let result = PatternMatcher.match(
      pathSegments: ["episodes", "season", "3", "sheesh-cab-bob"],
      queryItems: [:],
      against: [.literal("episodes"), .wildcard, .parameter("slug")],
      extractingQuery: []
    )

    XCTAssertNotNil(result)
    XCTAssertEqual(result?.path("slug"), "sheesh-cab-bob")
  }

  func testPatternMatcherExtractsQuery() {
    let result = PatternMatcher.match(
      pathSegments: ["menu"],
      queryItems: ["q": "burger", "page": "2", "unused": "value"],
      against: [.literal("menu")],
      extractingQuery: ["q", "page"]
    )

    XCTAssertNotNil(result)
    XCTAssertEqual(result?.query("q"), "burger")
    XCTAssertEqual(result?.query("page"), "2")
    XCTAssertNil(result?.query("unused"))
  }

  func testPatternMatcherFailsOnMismatch() {
    let result = PatternMatcher.match(
      pathSegments: ["burgers", "list"],
      queryItems: [:],
      against: [.literal("episodes"), .literal("list")],
      extractingQuery: []
    )

    XCTAssertNil(result)
  }

  func testPatternMatcherCaseInsensitive() {
    let result = PatternMatcher.match(
      pathSegments: ["BURGERS", "LIST"],
      queryItems: [:],
      against: [.literal("burgers"), .literal("list")],
      extractingQuery: []
    )

    XCTAssertNotNil(result)
  }
}
