//
//  BobsBurgersDemoTests.swift
//  BobsBurgersDemo
//
//  Tests for multi-tabbed deep link routing using Swift Testing framework.
//

import Foundation
import Testing
import CasePaths
@testable import BobsBurgersDemo
import DeepLinkRouting

// MARK: - Menu Destination Tests

@Suite("Menu Tab Routes")
struct MenuDestinationTests {
    let router = DeepLinkRouter<MenuDestination>()

    @Test("Matches /menu to list")
    func matchMenuList() {
        let result = router.match("/menu")
        #expect(result == .list)
    }

    @Test("Matches burger detail with ID")
    func matchBurgerDetail() {
        let result = router.match("/menu/burger/42")
        #expect(result == .burgerDetail(id: 42))
    }

    @Test("Matches burger of the day")
    func matchBurgerOfTheDay() {
        let result = router.match("/menu/burger-of-the-day")
        #expect(result == .burgerOfTheDay)
    }

    @Test("Matches sides")
    func matchSides() {
        let result = router.match("/menu/sides")
        #expect(result == .sides)
    }

    @Test("Matches drinks")
    func matchDrinks() {
        let result = router.match("/menu/drinks")
        #expect(result == .drinks)
    }

    @Test("Various burger IDs", arguments: [1, 7, 42, 100, 999])
    func burgerIdsParsed(id: Int) {
        let result = router.match("/menu/burger/\(id)")
        #expect(result == .burgerDetail(id: id))
    }

    @Test("CasePathable allows case checking")
    func casePathableWorks() {
        let dest = MenuDestination.burgerDetail(id: 42)

        // Using CasePaths is() operator for case checking
        #expect(dest.is(\.burgerDetail))
        #expect(!dest.is(\.list))
    }
}

// MARK: - Family Destination Tests

@Suite("Family Tab Routes")
struct FamilyDestinationTests {
    let router = DeepLinkRouter<FamilyDestination>()

    @Test("Matches /family to list")
    func matchFamilyList() {
        let result = router.match("/family")
        #expect(result == .list)
    }

    @Test("Matches family member", arguments: ["bob", "linda", "tina", "gene", "louise"])
    func matchFamilyMembers(name: String) {
        let result = router.match("/family/member/\(name)")
        #expect(result == .member(name: name))
    }

    @Test("Matches friends list")
    func matchFriends() {
        let result = router.match("/family/friends")
        #expect(result == .friends)
    }

    @Test("Matches specific friend")
    func matchFriend() {
        let result = router.match("/family/friends/teddy")
        #expect(result == .friend(name: "teddy"))
    }

    @Test("Matches staff")
    func matchStaff() {
        let result = router.match("/family/staff")
        #expect(result == .staff)
    }

    @Test("CasePathable allows pattern matching")
    func casePathablePatternMatching() {
        let dest = FamilyDestination.member(name: "tina")

        // Using is() for case checking
        #expect(dest.is(\.member))
        #expect(!dest.is(\.list))

        // Extract using standard pattern matching
        if case let .member(name) = dest {
            #expect(name == "tina")
        } else {
            Issue.record("Should extract member name")
        }
    }
}

// MARK: - Episodes Destination Tests

@Suite("Episodes Tab Routes")
struct EpisodesDestinationTests {
    let router = DeepLinkRouter<EpisodesDestination>()

    @Test("Matches /episodes to list")
    func matchEpisodesList() {
        let result = router.match("/episodes")
        #expect(result == .list)
    }

    @Test("Matches season", arguments: [1, 5, 10, 14])
    func matchSeason(number: Int) {
        let result = router.match("/episodes/season/\(number)")
        #expect(result == .season(number: number))
    }

    @Test("Matches specific episode")
    func matchEpisode() {
        let result = router.match("/episodes/3/12")
        #expect(result == .episode(season: 3, episode: 12))
    }

    @Test("Matches search with query")
    func matchSearchWithQuery() {
        let result = router.match("/episodes/search?q=burger")
        #expect(result == .search(q: "burger"))
    }

    @Test("Matches search without query")
    func matchSearchWithoutQuery() {
        let result = router.match("/episodes/search")
        #expect(result == .search(q: nil))
    }

    @Test("Matches favorites")
    func matchFavorites() {
        let result = router.match("/episodes/favorites")
        #expect(result == .favorites)
    }

    @Test("Episode combinations", arguments: [(1, 1), (3, 12), (5, 21), (14, 5)])
    func episodeCombinations(season: Int, episode: Int) {
        let result = router.match("/episodes/\(season)/\(episode)")
        #expect(result == .episode(season: season, episode: episode))
    }
}

// MARK: - Order Destination Tests

@Suite("Order Tab Routes")
struct OrderDestinationTests {
    let router = DeepLinkRouter<OrderDestination>()

    @Test("Matches /order to new")
    func matchNewOrder() {
        let result = router.match("/order")
        #expect(result == .new)
    }

    @Test("Matches promo code", arguments: ["FREEFRIES", "BURGERLOVER", "BELCHER20"])
    func matchPromoCode(code: String) {
        let result = router.match("/order/promo/\(code)")
        #expect(result == .withPromo(code: code))
    }

    @Test("Matches cart")
    func matchCart() {
        let result = router.match("/order/cart")
        #expect(result == .cart)
    }

    @Test("Matches order tracking")
    func matchTrackOrder() {
        let result = router.match("/order/track/ORD-12345")
        #expect(result == .track(orderId: "ORD-12345"))
    }

    @Test("Matches order history")
    func matchHistory() {
        let result = router.match("/order/history")
        #expect(result == .history)
    }
}

// MARK: - App Router Tests

@Suite("App Router")
struct AppRouterTests {

    @Test("Routes to correct tab - Menu")
    func routesToMenuTab() {
        let router = AppRouter()
        router.handleDeepLink("/menu/burger-of-the-day")

        #expect(router.selectedTab == .menu)
        #expect(router.lastDeepLink == "/menu/burger-of-the-day")
    }

    @Test("Routes to correct tab - Family")
    func routesToFamilyTab() {
        let router = AppRouter()
        router.handleDeepLink("/family/member/tina")

        #expect(router.selectedTab == .family)
    }

    @Test("Routes to correct tab - Episodes")
    func routesToEpisodesTab() {
        let router = AppRouter()
        router.handleDeepLink("/episodes/season/5")

        #expect(router.selectedTab == .episodes)
    }

    @Test("Routes to correct tab - Order")
    func routesToOrderTab() {
        let router = AppRouter()
        router.handleDeepLink("/order/cart")

        #expect(router.selectedTab == .order)
    }

    @Test("All routes are registered")
    func allRoutesRegistered() {
        let router = AppRouter()
        let routes = router.allRoutes

        // 5 menu + 5 family + 5 episodes + 5 order = 20 routes
        #expect(routes.count == 20)

        // Check each tab has routes
        #expect(routes.filter { $0.tab == "Menu" }.count == 5)
        #expect(routes.filter { $0.tab == "Family" }.count == 5)
        #expect(routes.filter { $0.tab == "Episodes" }.count == 5)
        #expect(routes.filter { $0.tab == "Order" }.count == 5)
    }

    @Test("Handles URL objects")
    func handlesURLObjects() {
        let router = AppRouter()
        let url = URL(string: "bobsburgers://app/family/member/louise")!
        router.handleDeepLink(url)

        #expect(router.selectedTab == .family)
    }
}

// MARK: - CasePathable Integration Tests

@Suite("CasePathable Integration")
struct CasePathableTests {

    @Test("Can use case paths for value extraction")
    func valueExtraction() {
        let menu = MenuDestination.burgerDetail(id: 42)
        let family = FamilyDestination.member(name: "gene")
        let episodes = EpisodesDestination.episode(season: 3, episode: 12)
        let order = OrderDestination.withPromo(code: "TEST")

        // Use optional binding for CasePath extraction
        if case let .burgerDetail(id) = menu {
            #expect(id == 42)
        } else {
            Issue.record("Should be burgerDetail")
        }

        if case let .member(name) = family {
            #expect(name == "gene")
        } else {
            Issue.record("Should be member")
        }

        if case let .episode(season, episode) = episodes {
            #expect(season == 3)
            #expect(episode == 12)
        } else {
            Issue.record("Should be episode")
        }

        if case let .withPromo(code) = order {
            #expect(code == "TEST")
        } else {
            Issue.record("Should be withPromo")
        }
    }

    @Test("Can use is operator for case checking")
    func caseChecking() {
        let dest = FamilyDestination.member(name: "bob")

        #expect(dest.is(\.member))
        #expect(!dest.is(\.list))
        #expect(!dest.is(\.friends))
    }

    @Test("Modify operator works with case paths")
    func modifyOperator() {
        var dest = MenuDestination.burgerDetail(id: 10)

        // Use modify to update associated value
        dest.modify(\.burgerDetail) { id in
            id += 5
        }

        if case let .burgerDetail(id) = dest {
            #expect(id == 15)
        } else {
            Issue.record("Should still be burgerDetail")
        }
    }
}

// MARK: - Route Pattern Tests

@Suite("Route Patterns")
struct RoutePatternTests {

    @Test("Menu routes have expected patterns")
    func menuPatterns() {
        let router = DeepLinkRouter<MenuDestination>()
        let patterns = router.routes.map { $0.pattern }

        #expect(patterns.contains("/menu"))
        #expect(patterns.contains("/menu/burger/:id"))
        #expect(patterns.contains("/menu/burger-of-the-day"))
        #expect(patterns.contains("/menu/sides"))
        #expect(patterns.contains("/menu/drinks"))
    }

    @Test("Invalid paths return nil")
    func invalidPaths() {
        let menuRouter = DeepLinkRouter<MenuDestination>()
        let familyRouter = DeepLinkRouter<FamilyDestination>()

        #expect(menuRouter.match("/invalid") == nil)
        #expect(menuRouter.match("/family/member/bob") == nil)
        #expect(familyRouter.match("/menu/burger/42") == nil)
    }
}

// MARK: - AppTab Tests

@Suite("AppTab Enum")
struct AppTabTests {

    @Test("All tabs have titles")
    func tabTitles() {
        #expect(AppTab.menu.title == "Menu")
        #expect(AppTab.family.title == "Family")
        #expect(AppTab.episodes.title == "Episodes")
        #expect(AppTab.order.title == "Order")
    }

    @Test("All tabs have icons")
    func tabIcons() {
        for tab in AppTab.allCases {
            #expect(!tab.icon.isEmpty)
            #expect(!tab.selectedIcon.isEmpty)
        }
    }

    @Test("CaseIterable provides all cases")
    func allCases() {
        #expect(AppTab.allCases.count == 4)
    }
}
