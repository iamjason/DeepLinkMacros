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
  .package(url: "https://github.com/iamjason/DeepLinkMacros.git", from: "0.1.0"),
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
| `String?` | Missing | `nil` |
| `Int?` | Missing | `nil` |
| `Bool?` | Missing | `nil` |

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
params.path("id")          // String? from path
params.pathInt("id")       // Int? from path
params.query("q")          // String? from query
params.queryInt("page")    // Int? from query
params.queryBool("flag")   // Bool? from query
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
