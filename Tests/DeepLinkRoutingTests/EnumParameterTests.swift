//
//  EnumParameterTests.swift
//  DeepLinkMacros
//
//  Tests for RawRepresentable enum parameter support.
//

import XCTest
@testable import DeepLinkRouting

// MARK: - Test Enums

/// Test enum with String raw value
enum MessageSource: String {
  case careTeam = "Care Team"
  case dashboard = "Dashboard"
  case deepLink = "Deep Link"
  case profile = "Profile"
}

/// Test enum with Int raw value
enum Priority: Int {
  case low = 1
  case medium = 2
  case high = 3
}

/// Test enum with simple String raw value (no spaces)
enum Category: String {
  case sports
  case news
  case entertainment
}

// MARK: - RouteParameters Enum Accessor Tests

final class RouteParametersEnumTests: XCTestCase {

  // MARK: - String RawValue Enum Tests

  func testQueryEnumWithStringRawValue() {
    let params = RouteParameters(query: ["source": "Care Team"])
    let result: MessageSource? = params.queryEnum("source")
    XCTAssertEqual(result, .careTeam)
  }

  func testQueryEnumWithStringRawValueSimple() {
    let params = RouteParameters(query: ["category": "sports"])
    let result: Category? = params.queryEnum("category")
    XCTAssertEqual(result, .sports)
  }

  func testQueryEnumWithMissingParameter() {
    let params = RouteParameters(query: [:])
    let result: MessageSource? = params.queryEnum("source")
    XCTAssertNil(result)
  }

  func testQueryEnumWithInvalidValue() {
    let params = RouteParameters(query: ["source": "Invalid Value"])
    let result: MessageSource? = params.queryEnum("source")
    XCTAssertNil(result)
  }

  func testPathEnumWithStringRawValue() {
    let params = RouteParameters(path: ["source": "Dashboard"])
    let result: MessageSource? = params.pathEnum("source")
    XCTAssertEqual(result, .dashboard)
  }

  // MARK: - Int RawValue Enum Tests

  func testQueryEnumWithIntRawValue() {
    let params = RouteParameters(query: ["priority": "3"])
    let result: Priority? = params.queryEnum("priority")
    XCTAssertEqual(result, .high)
  }

  func testQueryEnumWithIntRawValueLow() {
    let params = RouteParameters(query: ["priority": "1"])
    let result: Priority? = params.queryEnum("priority")
    XCTAssertEqual(result, .low)
  }

  func testQueryEnumWithInvalidIntValue() {
    let params = RouteParameters(query: ["priority": "99"])
    let result: Priority? = params.queryEnum("priority")
    XCTAssertNil(result)
  }

  func testQueryEnumWithNonNumericForIntEnum() {
    let params = RouteParameters(query: ["priority": "high"])
    let result: Priority? = params.queryEnum("priority")
    XCTAssertNil(result)
  }

  func testPathEnumWithIntRawValue() {
    let params = RouteParameters(path: ["priority": "2"])
    let result: Priority? = params.pathEnum("priority")
    XCTAssertEqual(result, .medium)
  }
}

// MARK: - Router Enum Parameter Tests

/// Test destination with enum parameters
enum EnumTestDestination: Equatable, DeepLinkRoutable {
  case messageWithSource(id: Int, source: MessageSource?)
  case taskWithPriority(id: Int, priority: Priority)
  case simpleCategory(category: Category?)
  case mixedParams(id: Int, source: MessageSource?, priority: Priority?)
  case enumInPath(source: MessageSource, id: Int)

  static var allRoutes: [DeepLinkRouteDefinition<EnumTestDestination>] {
    [
      // Optional enum in query
      DeepLinkRouteDefinition(
        pattern: "/message/:id",
        segments: [.literal("message"), .parameter("id")],
        queryParams: ["source"],
        build: { params in
          guard let id = params.pathInt("id") else { return nil }
          let source: MessageSource? = params.queryEnum("source")
          return .messageWithSource(id: id, source: source)
        }
      ),
      // Required enum in query
      DeepLinkRouteDefinition(
        pattern: "/task/:id",
        segments: [.literal("task"), .parameter("id")],
        queryParams: ["priority"],
        build: { params in
          guard let id = params.pathInt("id") else { return nil }
          guard let priority: Priority = params.queryEnum("priority") else { return nil }
          return .taskWithPriority(id: id, priority: priority)
        }
      ),
      // Simple string enum
      DeepLinkRouteDefinition(
        pattern: "/browse",
        segments: [.literal("browse")],
        queryParams: ["category"],
        build: { params in
          let category: Category? = params.queryEnum("category")
          return .simpleCategory(category: category)
        }
      ),
      // Multiple enums
      DeepLinkRouteDefinition(
        pattern: "/combined/:id",
        segments: [.literal("combined"), .parameter("id")],
        queryParams: ["source", "priority"],
        build: { params in
          guard let id = params.pathInt("id") else { return nil }
          let source: MessageSource? = params.queryEnum("source")
          let priority: Priority? = params.queryEnum("priority")
          return .mixedParams(id: id, source: source, priority: priority)
        }
      ),
      // Enum in path parameter
      DeepLinkRouteDefinition(
        pattern: "/by-source/:source/:id",
        segments: [.literal("by-source"), .parameter("source"), .parameter("id")],
        queryParams: [],
        build: { params in
          guard let source: MessageSource = params.pathEnum("source") else { return nil }
          guard let id = params.pathInt("id") else { return nil }
          return .enumInPath(source: source, id: id)
        }
      ),
    ]
  }
}

final class EnumRoutingTests: XCTestCase {

  var router: DeepLinkRouter<EnumTestDestination>!

  override func setUp() {
    super.setUp()
    router = DeepLinkRouter()
  }

  // MARK: - Optional String Enum Tests

  func testOptionalEnumWithValue() {
    let result = router.match("/message/123?source=Care%20Team")
    XCTAssertEqual(result, .messageWithSource(id: 123, source: .careTeam))
  }

  func testOptionalEnumWithDifferentValue() {
    let result = router.match("/message/456?source=Dashboard")
    XCTAssertEqual(result, .messageWithSource(id: 456, source: .dashboard))
  }

  func testOptionalEnumMissing() {
    let result = router.match("/message/789")
    XCTAssertEqual(result, .messageWithSource(id: 789, source: nil))
  }

  func testOptionalEnumInvalid() {
    let result = router.match("/message/123?source=InvalidSource")
    XCTAssertEqual(result, .messageWithSource(id: 123, source: nil))
  }

  // MARK: - Required Int Enum Tests

  func testRequiredEnumWithValidValue() {
    let result = router.match("/task/100?priority=3")
    XCTAssertEqual(result, .taskWithPriority(id: 100, priority: .high))
  }

  func testRequiredEnumWithMediumPriority() {
    let result = router.match("/task/200?priority=2")
    XCTAssertEqual(result, .taskWithPriority(id: 200, priority: .medium))
  }

  func testRequiredEnumMissingFails() {
    let result = router.match("/task/300")
    XCTAssertNil(result) // Route doesn't match without required enum
  }

  func testRequiredEnumInvalidFails() {
    let result = router.match("/task/400?priority=99")
    XCTAssertNil(result) // Route doesn't match with invalid enum value
  }

  // MARK: - Simple String Enum Tests

  func testSimpleStringEnum() {
    let result = router.match("/browse?category=sports")
    XCTAssertEqual(result, .simpleCategory(category: .sports))
  }

  func testSimpleStringEnumNews() {
    let result = router.match("/browse?category=news")
    XCTAssertEqual(result, .simpleCategory(category: .news))
  }

  func testSimpleStringEnumMissing() {
    let result = router.match("/browse")
    XCTAssertEqual(result, .simpleCategory(category: nil))
  }

  // MARK: - Multiple Enums Tests

  func testMultipleEnums() {
    let result = router.match("/combined/50?source=Profile&priority=1")
    XCTAssertEqual(result, .mixedParams(id: 50, source: .profile, priority: .low))
  }

  func testMultipleEnumsPartial() {
    let result = router.match("/combined/60?source=Deep%20Link")
    XCTAssertEqual(result, .mixedParams(id: 60, source: .deepLink, priority: nil))
  }

  func testMultipleEnumsNone() {
    let result = router.match("/combined/70")
    XCTAssertEqual(result, .mixedParams(id: 70, source: nil, priority: nil))
  }

  // MARK: - Enum in Path Tests

  func testEnumInPath() {
    let result = router.match("/by-source/Dashboard/999")
    XCTAssertEqual(result, .enumInPath(source: .dashboard, id: 999))
  }

  func testEnumInPathWithSpaces() {
    let result = router.match("/by-source/Care%20Team/888")
    XCTAssertEqual(result, .enumInPath(source: .careTeam, id: 888))
  }

  func testEnumInPathInvalidFails() {
    let result = router.match("/by-source/InvalidSource/777")
    XCTAssertNil(result) // Route doesn't match with invalid enum
  }

  // MARK: - URL Object Tests

  func testEnumWithURLObject() {
    let url = URL(string: "https://example.com/message/123?source=Dashboard")!
    let result = router.match(url)
    XCTAssertEqual(result, .messageWithSource(id: 123, source: .dashboard))
  }

  func testEnumWithURLEncodedSpaces() {
    let url = URL(string: "https://example.com/message/456?source=Deep%20Link")!
    let result = router.match(url)
    XCTAssertEqual(result, .messageWithSource(id: 456, source: .deepLink))
  }
}

// MARK: - Default Value Tests

/// Test destination with default parameter values
enum DefaultValueDestination: Equatable, DeepLinkRoutable {
  case booking(displayName: String, providerId: Int)
  case profile(title: String, id: Int, showHeader: Bool)
  case search(source: String, term: String?, limit: Int)

  static var allRoutes: [DeepLinkRouteDefinition<DefaultValueDestination>] {
    [
      // displayName has default "Unknown" - simulating what macro would generate
      DeepLinkRouteDefinition(
        pattern: "/book/:providerId",
        segments: [.literal("book"), .parameter("providerId")],
        queryParams: [],
        build: { params in
          guard let providerId = params.pathInt("providerId") else { return nil }
          // displayName not extracted - uses default
          return .booking(displayName: "Unknown", providerId: providerId)
        }
      ),
      // Multiple defaults
      DeepLinkRouteDefinition(
        pattern: "/profile/:id",
        segments: [.literal("profile"), .parameter("id")],
        queryParams: [],
        build: { params in
          guard let id = params.pathInt("id") else { return nil }
          // title and showHeader use defaults
          return .profile(title: "Profile", id: id, showHeader: true)
        }
      ),
      // Mix of URL params and defaults
      DeepLinkRouteDefinition(
        pattern: "/search",
        segments: [.literal("search")],
        queryParams: ["term"],
        build: { params in
          let term = params.query("term")
          // source and limit use defaults
          return .search(source: "deep_link", term: term, limit: 20)
        }
      ),
    ]
  }
}

final class DefaultValueRoutingTests: XCTestCase {

  var router: DeepLinkRouter<DefaultValueDestination>!

  override func setUp() {
    super.setUp()
    router = DeepLinkRouter()
  }

  func testDefaultValueForUnmappedParameter() {
    let result = router.match("/book/123")
    XCTAssertEqual(result, .booking(displayName: "Unknown", providerId: 123))
  }

  func testMultipleDefaultValues() {
    let result = router.match("/profile/456")
    XCTAssertEqual(result, .profile(title: "Profile", id: 456, showHeader: true))
  }

  func testMixOfURLParamsAndDefaults() {
    let result = router.match("/search?term=swift")
    XCTAssertEqual(result, .search(source: "deep_link", term: "swift", limit: 20))
  }

  func testDefaultWithNilQueryParam() {
    let result = router.match("/search")
    XCTAssertEqual(result, .search(source: "deep_link", term: nil, limit: 20))
  }
}
