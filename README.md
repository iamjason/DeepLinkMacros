# DeepLinkMacros

> **Alpha Release** - This package is in early development. APIs may change between versions.

A Swift Macro package for declarative, type-safe deep link routing. Define URL patterns directly on enum cases and let the compiler generate all the routing code.

## Features

- **Declarative Routes** - Define URL patterns with `@DeepLinkRoute` directly on enum cases
- **Type-Safe** - Compile-time validation of route patterns and parameter types
- **Auto-Discovery** - Routes are automatically collected via `@DeepLinkDestination`
- **Multi-Enum Support** - `UniversalDeepLinkRouter` aggregates multiple destination enums
- **Pattern Matching** - Supports path parameters (`:id`), wildcards (`**`), and query parameters

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/iamjason/DeepLinkMacros.git", from: "0.1.1"),
]

targets: [
  .target(
    name: "YourTarget",
    dependencies: ["DeepLinkRouting"]
  ),
]
```

Or in Xcode: File → Add Package Dependencies → Enter the repository URL.

## Quick Start

```swift
import DeepLinkRouting

// 1. Define your destination enum with routes
@DeepLinkDestination
enum BobsBurgersDestination {
  @DeepLinkRoute("/employees/:id")
  case employee(employeeId: Int)

  @DeepLinkRoute("/menu", query: ["q", "page"])
  case menuSearch(query: String?, page: Int?)

  case kitchen  // No route = not deep-linkable
}

// 2. Create a router
let router = DeepLinkRouter<BobsBurgersDestination>()

// 3. Match URLs
router.match("/employees/1")        // → .employee(employeeId: 1)
router.match("/menu?q=burger")      // → .menuSearch(query: "burger", page: nil)
router.match("/unknown")            // → nil
```

## Pattern Syntax

### Path Parameters

Use `:name` to capture path segments:

```swift
@DeepLinkRoute("/employees/:id")
case employee(id: Int)

@DeepLinkRoute("/characters/:characterId/episodes/:episodeId")
case characterEpisode(characterId: Int, episodeId: Int)
```

Path parameters are mapped to case parameters **by position**.

### Query Parameters

Use the `query:` argument to extract query string parameters:

```swift
@DeepLinkRoute("/menu", query: ["q", "page", "category"])
case menuSearch(q: String?, page: Int?, category: String?)
```

Query parameters are mapped to case parameters **by name**.

### Wildcards

Use `**` to match any number of path segments:

```swift
@DeepLinkRoute("/episodes/**/:slug")
case episode(slug: String)

// Matches:
// /episodes/slug                    → .episode(slug: "slug")
// /episodes/season/3/slug           → .episode(slug: "slug")
// /episodes/season/3/part/2/slug    → .episode(slug: "slug")
```

### Supported Types

| Type | URL Value | Conversion |
|------|-----------|------------|
| `String` | Any | Direct |
| `Int` | `"123"` | `Int.init` |
| `Bool` | `"true"`, `"1"`, `"yes"` | `true` |
| `Bool` | `"false"`, `"0"`, `"no"` | `false` |
| `Double` | `"3.14"` | `Double.init` |
| `MyEnum` | `"rawValue"` | `MyEnum(rawValue:)` |
| `String?` | Missing | `nil` |
| `Int?` | Missing | `nil` |
| `Bool?` | Missing | `nil` |
| `Double?` | Missing | `nil` |
| `MyEnum?` | Missing/Invalid | `nil` |

### Array Parameters

Array parameters are supported in query strings using comma-separated values:

```swift
@DeepLinkDestination
enum SearchDestination {
  @DeepLinkRoute("/search", query: ["categories", "tags"])
  case search(categories: [Int]?, tags: [String]?)
}

// Matches: /search?categories=1,2,3&tags=swift,ios
// Result: .search(categories: [1, 2, 3], tags: ["swift", "ios"])
```

**Supported array types:**

| Type | URL Value | Result |
|------|-----------|--------|
| `[Int]?` | `"1,2,3"` | `[1, 2, 3]` |
| `[String]?` | `"a,b,c"` | `["a", "b", "c"]` |
| `[Double]?` | `"1.5,2.5"` | `[1.5, 2.5]` |
| `[Bool]?` | `"true,false"` | `[true, false]` |
| `[Int]` (required) | Missing | `[]` (empty array) |

**Notes:**
- Invalid elements are silently skipped (e.g., `"1,bad,3"` → `[1, 3]`)
- Whitespace is trimmed (e.g., `"1, 2, 3"` → `[1, 2, 3]`)
- Empty or missing values return `nil` for optional arrays, `[]` for required arrays
- Arrays are only supported in query parameters, not path parameters

### Enum Parameters

`RawRepresentable` enums with `String` or `Int` raw values are supported as parameters:

```swift
// Define your enum with RawRepresentable conformance
enum MessageSource: String {
  case careTeam = "care_team"
  case dashboard = "dashboard"
  case deepLink = "deep_link"
}

enum Priority: Int {
  case low = 1
  case medium = 2
  case high = 3
}

@DeepLinkDestination
enum MessageDestination {
  // Optional enum in query parameter
  @DeepLinkRoute("/message/:id", query: ["source"])
  case message(id: Int, source: MessageSource?)

  // Required enum in query parameter
  @DeepLinkRoute("/task/:id", query: ["priority"])
  case task(id: Int, priority: Priority)

  // Enum in path parameter
  @DeepLinkRoute("/by-source/:source/:id")
  case bySource(source: MessageSource, id: Int)
}

// Matches:
// /message/123?source=dashboard       → .message(id: 123, source: .dashboard)
// /message/123                        → .message(id: 123, source: nil)
// /task/456?priority=3                → .task(id: 456, priority: .high)
// /by-source/care_team/789            → .bySource(source: .careTeam, id: 789)
```

**Notes:**
- Enums must conform to `RawRepresentable` with `String` or `Int` raw values
- Invalid enum values return `nil` for optional parameters
- Invalid enum values cause route match failure for required parameters
- Arrays of enums are not supported

### Default Parameter Values

Parameters with default values are automatically skipped during URL extraction:

```swift
@DeepLinkDestination
enum BookingDestination {
  @DeepLinkRoute("/book/:providerId")
  case booking(displayName: String = "Unknown", providerId: Int)
}

// Matches: /book/123 → .booking(displayName: "Unknown", providerId: 123)
```

This is useful for parameters that should always use a fixed value when navigating via deep link, but can be customized when creating the destination programmatically.

## Multi-Enum Routing

For apps with separate destination enums per section, use `UniversalDeepLinkRouter`:

```swift
// Each section has its own destination enum
@DeepLinkDestination
enum RestaurantDestination {
  @DeepLinkRoute("/burgers/:slug")
  case burgerOfTheDay(slug: String)
}

@DeepLinkDestination
enum WharfDestination {
  @DeepLinkRoute("/rides/:id")
  case ride(rideId: Int)
}

@DeepLinkDestination
enum SchoolDestination {
  @DeepLinkRoute("/cafeteria")
  case cafeteria
}

// Wrapper enum (no macro needed)
enum AppDestination {
  case restaurant(RestaurantDestination)
  case wharf(WharfDestination)
  case school(SchoolDestination)
}

// Configure universal router
let router = UniversalDeepLinkRouter<AppDestination>()
  .include(RestaurantDestination.self, as: AppDestination.restaurant)
  .include(WharfDestination.self, as: AppDestination.wharf)
  .include(SchoolDestination.self, as: AppDestination.school)

// Match URLs - section context is automatic!
router.match("/burgers/new-bacon-ings")  // → .restaurant(.burgerOfTheDay(slug: "new-bacon-ings"))
router.match("/rides/42")                 // → .wharf(.ride(rideId: 42))
router.match("/cafeteria")                // → .school(.cafeteria)
```

## API Reference

### `@DeepLinkRoute`

Attached to enum cases to define URL patterns.

```swift
@DeepLinkRoute(_ pattern: String, query: [String] = [])
```

- `pattern` - URL pattern with path parameters (`:name`) and wildcards (`**`)
- `query` - Array of query parameter names to extract

### `@DeepLinkDestination`

Attached to enums to generate `DeepLinkRoutable` conformance.

```swift
@DeepLinkDestination
enum MyDestination { ... }
```

Generates:
- `DeepLinkRoutable` protocol conformance
- `allRoutes` static property collecting all `@DeepLinkRoute` cases

### `DeepLinkRouter<Destination>`

Router for a single destination enum.

```swift
let router = DeepLinkRouter<BobsBurgersDestination>()

// Match URL string
let dest: BobsBurgersDestination? = router.match("/employees/1")

// Match URL object
let dest: BobsBurgersDestination? = router.match(url)

// Get detailed match info
let result = router.matchWithDetails("/employees/1")
result?.destination   // The matched case
result?.pattern       // "/employees/:id"
result?.parameters    // RouteParameters with extracted values
```

### `UniversalDeepLinkRouter<Wrapper>`

Router that aggregates multiple destination enums.

```swift
let router = UniversalDeepLinkRouter<AppDestination>()
  .include(RestaurantDestination.self, as: AppDestination.restaurant)
  .include(WharfDestination.self, as: AppDestination.wharf)

router.match("/burgers/test")  // → .restaurant(.burgerOfTheDay(slug: "test"))

// Detailed results include source type
let result = router.matchWithDetails("/burgers/test")
result?.sourceType  // "RestaurantDestination"
```

### `RouteParameters`

Extracted URL parameters.

```swift
// Scalar accessors
params.path("id")          // String? from path
params.pathInt("id")       // Int? from path
params.query("q")          // String? from query
params.queryInt("page")    // Int? from query
params.queryBool("flag")   // Bool? from query

// Array accessors (comma-separated values)
params.queryInts("ids")    // [Int]? from query
params.queryStrings("tags")// [String]? from query
params.queryDoubles("prices") // [Double]? from query
params.queryBools("flags") // [Bool]? from query

// Enum accessors (RawRepresentable with String or Int)
let source: MyEnum? = params.queryEnum("source")
let priority: MyEnum? = params.pathEnum("priority")
```

## Adding New Routes

Adding a new deep link is a one-liner:

```swift
// Just add @DeepLinkRoute to any case
@DeepLinkRoute("/specials/:id")
case dailySpecial(specialId: Int)
```

The router automatically discovers new routes - no manual registration needed.

## Handling Deep Links

```swift
func handleDeepLink(_ url: URL) {
  guard let destination = router.match(url) else {
    // No match - open in browser
    openInBrowser(url)
    return
  }

  switch destination {
  case .restaurant(let dest):
    navigate(to: dest)
  case .wharf(let dest):
    tabController.selectTab(.wharf)
    wharfCoordinator.navigate(to: dest)
  case .school(let dest):
    tabController.selectTab(.school)
    schoolCoordinator.navigate(to: dest)
  }
}
```

## Testing

Run tests with:

```bash
swift test
```

## Requirements

- Swift 5.9+
- iOS 15+ / macOS 12+

## License

MIT License. See LICENSE file for details.
