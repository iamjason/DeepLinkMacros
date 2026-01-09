//
//  ArrayParameterTests.swift
//  DeepLinkMacros
//
//  Tests for comma-separated array parameter support.
//

import XCTest
@testable import DeepLinkRouting

// MARK: - RouteParameters Array Accessor Tests

final class RouteParametersArrayTests: XCTestCase {

  // MARK: - Int Array Tests

  func testQueryIntsWithMultipleValues() {
    let params = RouteParameters(query: ["ids": "1,2,3"])
    XCTAssertEqual(params.queryInts("ids"), [1, 2, 3])
  }

  func testQueryIntsWithSingleValue() {
    let params = RouteParameters(query: ["ids": "42"])
    XCTAssertEqual(params.queryInts("ids"), [42])
  }

  func testQueryIntsWithEmptyString() {
    let params = RouteParameters(query: ["ids": ""])
    XCTAssertNil(params.queryInts("ids"))
  }

  func testQueryIntsWithMissingParameter() {
    let params = RouteParameters(query: [:])
    XCTAssertNil(params.queryInts("ids"))
  }

  func testQueryIntsSkipsInvalidElements() {
    let params = RouteParameters(query: ["ids": "1,invalid,3,bad,5"])
    XCTAssertEqual(params.queryInts("ids"), [1, 3, 5])
  }

  func testQueryIntsWithWhitespace() {
    let params = RouteParameters(query: ["ids": "1, 2, 3"])
    XCTAssertEqual(params.queryInts("ids"), [1, 2, 3])
  }

  func testQueryIntsWithLeadingComma() {
    let params = RouteParameters(query: ["ids": ",1,2,3"])
    XCTAssertEqual(params.queryInts("ids"), [1, 2, 3])
  }

  func testQueryIntsWithTrailingComma() {
    let params = RouteParameters(query: ["ids": "1,2,3,"])
    XCTAssertEqual(params.queryInts("ids"), [1, 2, 3])
  }

  func testQueryIntsReturnsNilWhenAllInvalid() {
    let params = RouteParameters(query: ["ids": "a,b,c"])
    XCTAssertNil(params.queryInts("ids"))
  }

  // MARK: - String Array Tests

  func testQueryStringsWithMultipleValues() {
    let params = RouteParameters(query: ["tags": "swift,ios,macros"])
    XCTAssertEqual(params.queryStrings("tags"), ["swift", "ios", "macros"])
  }

  func testQueryStringsWithSingleValue() {
    let params = RouteParameters(query: ["tags": "swift"])
    XCTAssertEqual(params.queryStrings("tags"), ["swift"])
  }

  func testQueryStringsWithEmptyString() {
    let params = RouteParameters(query: ["tags": ""])
    XCTAssertNil(params.queryStrings("tags"))
  }

  func testQueryStringsWithMissingParameter() {
    let params = RouteParameters(query: [:])
    XCTAssertNil(params.queryStrings("tags"))
  }

  func testQueryStringsTrimsWhitespace() {
    let params = RouteParameters(query: ["tags": "swift , ios , macros"])
    XCTAssertEqual(params.queryStrings("tags"), ["swift", "ios", "macros"])
  }

  func testQueryStringsFiltersEmptyElements() {
    let params = RouteParameters(query: ["tags": "swift,,ios"])
    XCTAssertEqual(params.queryStrings("tags"), ["swift", "ios"])
  }

  // MARK: - Double Array Tests

  func testQueryDoublesWithMultipleValues() {
    let params = RouteParameters(query: ["prices": "9.99,19.99,29.99"])
    XCTAssertEqual(params.queryDoubles("prices"), [9.99, 19.99, 29.99])
  }

  func testQueryDoublesWithIntegers() {
    let params = RouteParameters(query: ["prices": "10,20,30"])
    XCTAssertEqual(params.queryDoubles("prices"), [10.0, 20.0, 30.0])
  }

  func testQueryDoublesSkipsInvalidElements() {
    let params = RouteParameters(query: ["prices": "9.99,invalid,29.99"])
    XCTAssertEqual(params.queryDoubles("prices"), [9.99, 29.99])
  }

  // MARK: - Bool Array Tests

  func testQueryBoolsWithMultipleValues() {
    let params = RouteParameters(query: ["flags": "true,false,true"])
    XCTAssertEqual(params.queryBools("flags"), [true, false, true])
  }

  func testQueryBoolsWithNumericValues() {
    let params = RouteParameters(query: ["flags": "1,0,1"])
    XCTAssertEqual(params.queryBools("flags"), [true, false, true])
  }

  func testQueryBoolsWithYesNo() {
    let params = RouteParameters(query: ["flags": "yes,no,yes"])
    XCTAssertEqual(params.queryBools("flags"), [true, false, true])
  }

  func testQueryBoolsCaseInsensitive() {
    let params = RouteParameters(query: ["flags": "TRUE,False,YES"])
    XCTAssertEqual(params.queryBools("flags"), [true, false, true])
  }

  func testQueryBoolsSkipsInvalidElements() {
    let params = RouteParameters(query: ["flags": "true,maybe,false"])
    XCTAssertEqual(params.queryBools("flags"), [true, false])
  }
}

// MARK: - Router Array Parameter Tests

/// Test destination with array parameters
enum ArrayTestDestination: Equatable, DeepLinkRoutable {
  case searchWithIds(ids: [Int]?)
  case filterWithTags(tags: [String]?)
  case requiredArray(values: [Int])
  case mixedParams(name: String?, ids: [Int]?)

  static var allRoutes: [DeepLinkRouteDefinition<ArrayTestDestination>] {
    [
      // Optional [Int]?
      DeepLinkRouteDefinition(
        pattern: "/search",
        segments: [.literal("search")],
        queryParams: ["ids"],
        build: { params in
          let ids = params.queryInts("ids")
          return .searchWithIds(ids: ids)
        }
      ),
      // Optional [String]?
      DeepLinkRouteDefinition(
        pattern: "/filter",
        segments: [.literal("filter")],
        queryParams: ["tags"],
        build: { params in
          let tags = params.queryStrings("tags")
          return .filterWithTags(tags: tags)
        }
      ),
      // Required [Int] - defaults to []
      DeepLinkRouteDefinition(
        pattern: "/required",
        segments: [.literal("required")],
        queryParams: ["values"],
        build: { params in
          let values = params.queryInts("values") ?? []
          return .requiredArray(values: values)
        }
      ),
      // Mixed scalar and array
      DeepLinkRouteDefinition(
        pattern: "/mixed",
        segments: [.literal("mixed")],
        queryParams: ["name", "ids"],
        build: { params in
          let name = params.query("name")
          let ids = params.queryInts("ids")
          return .mixedParams(name: name, ids: ids)
        }
      ),
    ]
  }
}

final class ArrayRoutingTests: XCTestCase {

  var router: DeepLinkRouter<ArrayTestDestination>!

  override func setUp() {
    super.setUp()
    router = DeepLinkRouter()
  }

  // MARK: - Optional Int Array

  func testSearchWithIds() {
    let result = router.match("/search?ids=1,2,3")
    XCTAssertEqual(result, .searchWithIds(ids: [1, 2, 3]))
  }

  func testSearchWithSingleId() {
    let result = router.match("/search?ids=42")
    XCTAssertEqual(result, .searchWithIds(ids: [42]))
  }

  func testSearchWithNoIds() {
    let result = router.match("/search")
    XCTAssertEqual(result, .searchWithIds(ids: nil))
  }

  func testSearchWithEmptyIds() {
    let result = router.match("/search?ids=")
    XCTAssertEqual(result, .searchWithIds(ids: nil))
  }

  func testSearchSkipsInvalidIds() {
    let result = router.match("/search?ids=1,bad,3")
    XCTAssertEqual(result, .searchWithIds(ids: [1, 3]))
  }

  // MARK: - Optional String Array

  func testFilterWithTags() {
    let result = router.match("/filter?tags=swift,ios,macros")
    XCTAssertEqual(result, .filterWithTags(tags: ["swift", "ios", "macros"]))
  }

  func testFilterWithNoTags() {
    let result = router.match("/filter")
    XCTAssertEqual(result, .filterWithTags(tags: nil))
  }

  // MARK: - Required Array

  func testRequiredArrayWithValues() {
    let result = router.match("/required?values=1,2,3")
    XCTAssertEqual(result, .requiredArray(values: [1, 2, 3]))
  }

  func testRequiredArrayWithNoValues() {
    let result = router.match("/required")
    XCTAssertEqual(result, .requiredArray(values: []))
  }

  func testRequiredArrayWithEmptyString() {
    let result = router.match("/required?values=")
    XCTAssertEqual(result, .requiredArray(values: []))
  }

  // MARK: - Mixed Scalar and Array

  func testMixedParams() {
    let result = router.match("/mixed?name=test&ids=1,2,3")
    XCTAssertEqual(result, .mixedParams(name: "test", ids: [1, 2, 3]))
  }

  func testMixedParamsOnlyName() {
    let result = router.match("/mixed?name=test")
    XCTAssertEqual(result, .mixedParams(name: "test", ids: nil))
  }

  func testMixedParamsOnlyIds() {
    let result = router.match("/mixed?ids=1,2,3")
    XCTAssertEqual(result, .mixedParams(name: nil, ids: [1, 2, 3]))
  }

  func testMixedParamsNone() {
    let result = router.match("/mixed")
    XCTAssertEqual(result, .mixedParams(name: nil, ids: nil))
  }

  // MARK: - URL Encoded Values

  func testURLEncodedCommas() {
    // URL-encoded comma is %2C - but since URLComponents decodes it,
    // this should work the same as regular commas
    let url = URL(string: "https://example.com/search?ids=1%2C2%2C3")!
    let result = router.match(url)
    XCTAssertEqual(result, .searchWithIds(ids: [1, 2, 3]))
  }
}
