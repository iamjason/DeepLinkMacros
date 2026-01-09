//
//  BobsBurgersUITests.swift
//  BobsBurgersDemo
//
//  UI Tests verifying deep link routing and tab switching.
//

import XCTest

final class BobsBurgersUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tab Bar Tests

    func testTabBarExists() throws {
        XCTAssertTrue(app.tabBars.firstMatch.exists)
        XCTAssertTrue(app.tabBars.buttons["Menu"].exists)
        XCTAssertTrue(app.tabBars.buttons["Family"].exists)
        XCTAssertTrue(app.tabBars.buttons["Episodes"].exists)
        XCTAssertTrue(app.tabBars.buttons["Order"].exists)
    }

    func testTabSwitching() throws {
        // Start on Menu tab
        XCTAssertTrue(app.navigationBars["Menu"].exists)

        // Switch to Family tab
        app.tabBars.buttons["Family"].tap()
        XCTAssertTrue(app.navigationBars["Family"].waitForExistence(timeout: 2))

        // Switch to Episodes tab
        app.tabBars.buttons["Episodes"].tap()
        XCTAssertTrue(app.navigationBars["Episodes"].waitForExistence(timeout: 2))

        // Switch to Order tab
        app.tabBars.buttons["Order"].tap()
        XCTAssertTrue(app.navigationBars["Order"].waitForExistence(timeout: 2))

        // Switch back to Menu
        app.tabBars.buttons["Menu"].tap()
        XCTAssertTrue(app.navigationBars["Menu"].waitForExistence(timeout: 2))
    }

    // MARK: - Menu Tab Deep Link Tests

    func testDeepLinkMenuBurgerOfTheDay() throws {
        openDeepLink("bobsburgers://app/menu/burger-of-the-day")

        XCTAssertTrue(app.tabBars.buttons["Menu"].isSelected)
        XCTAssertTrue(app.navigationBars["Burger of the Day"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Burger of the Day"].exists)
    }

    func testDeepLinkBurgerDetail() throws {
        openDeepLink("bobsburgers://app/menu/burger/42")

        XCTAssertTrue(app.tabBars.buttons["Menu"].isSelected)
        XCTAssertTrue(app.navigationBars["Burger #42"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Burger #42"].exists)
    }

    func testDeepLinkSides() throws {
        openDeepLink("bobsburgers://app/menu/sides")

        XCTAssertTrue(app.tabBars.buttons["Menu"].isSelected)
        XCTAssertTrue(app.navigationBars["Sides"].waitForExistence(timeout: 3))
    }

    func testDeepLinkDrinks() throws {
        openDeepLink("bobsburgers://app/menu/drinks")

        XCTAssertTrue(app.tabBars.buttons["Menu"].isSelected)
        XCTAssertTrue(app.navigationBars["Drinks"].waitForExistence(timeout: 3))
    }

    // MARK: - Family Tab Deep Link Tests

    func testDeepLinkFamilyList() throws {
        openDeepLink("bobsburgers://app/family")

        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["The Belchers"].waitForExistence(timeout: 3))
    }

    func testDeepLinkFamilyMemberTina() throws {
        openDeepLink("bobsburgers://app/family/member/tina")

        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Tina"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Tina"].exists)
    }

    func testDeepLinkFamilyMemberLouise() throws {
        openDeepLink("bobsburgers://app/family/member/louise")

        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Louise"].waitForExistence(timeout: 3))
    }

    func testDeepLinkFamilyMemberBob() throws {
        openDeepLink("bobsburgers://app/family/member/bob")

        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Bob"].waitForExistence(timeout: 3))
    }

    func testDeepLinkFriends() throws {
        openDeepLink("bobsburgers://app/family/friends")

        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Friends"].waitForExistence(timeout: 3))
    }

    func testDeepLinkFriendTeddy() throws {
        openDeepLink("bobsburgers://app/family/friends/teddy")

        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Teddy"].waitForExistence(timeout: 3))
    }

    func testDeepLinkStaff() throws {
        openDeepLink("bobsburgers://app/family/staff")

        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Staff"].waitForExistence(timeout: 3))
    }

    // MARK: - Episodes Tab Deep Link Tests

    func testDeepLinkEpisodesList() throws {
        openDeepLink("bobsburgers://app/episodes")

        XCTAssertTrue(app.tabBars.buttons["Episodes"].isSelected)
        XCTAssertTrue(app.navigationBars["All Seasons"].waitForExistence(timeout: 3))
    }

    func testDeepLinkSeason() throws {
        openDeepLink("bobsburgers://app/episodes/season/5")

        XCTAssertTrue(app.tabBars.buttons["Episodes"].isSelected)
        XCTAssertTrue(app.navigationBars["Season 5"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Season 5"].exists)
    }

    func testDeepLinkEpisode() throws {
        openDeepLink("bobsburgers://app/episodes/3/12")

        XCTAssertTrue(app.tabBars.buttons["Episodes"].isSelected)
        XCTAssertTrue(app.navigationBars["S3E12"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["S3E12"].exists)
    }

    func testDeepLinkFavorites() throws {
        openDeepLink("bobsburgers://app/episodes/favorites")

        XCTAssertTrue(app.tabBars.buttons["Episodes"].isSelected)
        XCTAssertTrue(app.navigationBars["Favorites"].waitForExistence(timeout: 3))
    }

    // MARK: - Order Tab Deep Link Tests

    func testDeepLinkNewOrder() throws {
        openDeepLink("bobsburgers://app/order")

        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)
        XCTAssertTrue(app.navigationBars["New Order"].waitForExistence(timeout: 3))
    }

    func testDeepLinkOrderWithPromo() throws {
        openDeepLink("bobsburgers://app/order/promo/FREEFRIES")

        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)
        XCTAssertTrue(app.navigationBars["Promo: FREEFRIES"].waitForExistence(timeout: 3))
    }

    func testDeepLinkCart() throws {
        openDeepLink("bobsburgers://app/order/cart")

        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)
        XCTAssertTrue(app.navigationBars["Cart"].waitForExistence(timeout: 3))
    }

    func testDeepLinkTrackOrder() throws {
        openDeepLink("bobsburgers://app/order/track/ORD-12345")

        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)
        XCTAssertTrue(app.navigationBars["Order ORD-12345"].waitForExistence(timeout: 3))
    }

    func testDeepLinkOrderHistory() throws {
        openDeepLink("bobsburgers://app/order/history")

        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)
        XCTAssertTrue(app.navigationBars["Order History"].waitForExistence(timeout: 3))
    }

    // MARK: - Tab Switching via Deep Links

    func testDeepLinkSwitchesFromMenuToFamily() throws {
        // Start on Menu tab
        XCTAssertTrue(app.tabBars.buttons["Menu"].isSelected)

        // Deep link to Family
        openDeepLink("bobsburgers://app/family/member/gene")

        // Should switch to Family tab
        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Gene"].waitForExistence(timeout: 3))
    }

    func testDeepLinkSwitchesFromFamilyToEpisodes() throws {
        // Go to Family tab first
        app.tabBars.buttons["Family"].tap()
        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)

        // Deep link to Episodes
        openDeepLink("bobsburgers://app/episodes/season/10")

        // Should switch to Episodes tab
        XCTAssertTrue(app.tabBars.buttons["Episodes"].isSelected)
        XCTAssertTrue(app.navigationBars["Season 10"].waitForExistence(timeout: 3))
    }

    func testDeepLinkSwitchesFromEpisodesToOrder() throws {
        // Go to Episodes tab first
        app.tabBars.buttons["Episodes"].tap()
        XCTAssertTrue(app.tabBars.buttons["Episodes"].isSelected)

        // Deep link to Order
        openDeepLink("bobsburgers://app/order/cart")

        // Should switch to Order tab
        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)
        XCTAssertTrue(app.navigationBars["Cart"].waitForExistence(timeout: 3))
    }

    func testDeepLinkSwitchesFromOrderToMenu() throws {
        // Go to Order tab first
        app.tabBars.buttons["Order"].tap()
        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)

        // Deep link to Menu
        openDeepLink("bobsburgers://app/menu/burger/99")

        // Should switch to Menu tab
        XCTAssertTrue(app.tabBars.buttons["Menu"].isSelected)
        XCTAssertTrue(app.navigationBars["Burger #99"].waitForExistence(timeout: 3))
    }

    // MARK: - Navigation Back Button Tests

    func testCanNavigateBackAfterDeepLink() throws {
        openDeepLink("bobsburgers://app/menu/burger/42")

        XCTAssertTrue(app.navigationBars["Burger #42"].waitForExistence(timeout: 3))

        // Tap back button
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Should be back at Menu list
        XCTAssertTrue(app.navigationBars["Menu"].waitForExistence(timeout: 2))
    }

    // MARK: - Multiple Sequential Deep Links

    func testMultipleSequentialDeepLinks() throws {
        // First deep link - Menu
        openDeepLink("bobsburgers://app/menu/burger-of-the-day")
        XCTAssertTrue(app.navigationBars["Burger of the Day"].waitForExistence(timeout: 3))

        // Second deep link - Family (different tab)
        openDeepLink("bobsburgers://app/family/member/linda")
        XCTAssertTrue(app.tabBars.buttons["Family"].isSelected)
        XCTAssertTrue(app.navigationBars["Linda"].waitForExistence(timeout: 3))

        // Third deep link - Episodes (different tab)
        openDeepLink("bobsburgers://app/episodes/1/1")
        XCTAssertTrue(app.tabBars.buttons["Episodes"].isSelected)
        XCTAssertTrue(app.navigationBars["S1E1"].waitForExistence(timeout: 3))

        // Fourth deep link - Order (different tab)
        openDeepLink("bobsburgers://app/order/promo/BELCHER20")
        XCTAssertTrue(app.tabBars.buttons["Order"].isSelected)
        XCTAssertTrue(app.navigationBars["Promo: BELCHER20"].waitForExistence(timeout: 3))
    }

    // MARK: - Helper Methods

    private func openDeepLink(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            XCTFail("Invalid URL: \(urlString)")
            return
        }

        // Use XCUIDevice to open the URL (available iOS 16+)
        XCUIDevice.shared.system.open(url)

        // Wait for app to handle the deep link
        _ = app.wait(for: .runningForeground, timeout: 3)
    }
}

// MARK: - In-App Navigation Tests

final class BobsBurgersNavigationUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Menu Tab Navigation

    func testMenuTabNavigationToBurgerOfTheDay() throws {
        // Find and tap Burger of the Day in the list (SwiftUI NavigationLink with Label)
        let burgerOfTheDayButton = app.buttons["Burger of the Day"]
        XCTAssertTrue(burgerOfTheDayButton.waitForExistence(timeout: 2))
        burgerOfTheDayButton.tap()

        // Verify navigation
        XCTAssertTrue(app.navigationBars["Burger of the Day"].waitForExistence(timeout: 2))
    }

    func testMenuTabNavigationToSides() throws {
        let sidesCell = app.cells.staticTexts["Sides"]
        XCTAssertTrue(sidesCell.waitForExistence(timeout: 2))
        sidesCell.tap()

        XCTAssertTrue(app.navigationBars["Sides"].waitForExistence(timeout: 2))
    }

    // MARK: - Family Tab Navigation

    func testFamilyTabNavigationToMember() throws {
        // Switch to Family tab
        app.tabBars.buttons["Family"].tap()

        // Find and tap Tina
        let tinaCell = app.cells.staticTexts["Tina"]
        XCTAssertTrue(tinaCell.waitForExistence(timeout: 2))
        tinaCell.tap()

        // Verify navigation
        XCTAssertTrue(app.navigationBars["Tina"].waitForExistence(timeout: 2))
    }

    func testFamilyTabNavigationToFriends() throws {
        // Switch to Family tab
        app.tabBars.buttons["Family"].tap()

        // Find and tap Friends (SwiftUI NavigationLink with Label)
        let friendsButton = app.buttons["Friends"]
        XCTAssertTrue(friendsButton.waitForExistence(timeout: 2))
        friendsButton.tap()

        XCTAssertTrue(app.navigationBars["Friends"].waitForExistence(timeout: 2))
    }

    // MARK: - Episodes Tab Navigation

    func testEpisodesTabNavigationToSeason() throws {
        // Switch to Episodes tab
        app.tabBars.buttons["Episodes"].tap()

        // Scroll down to find Season 5
        let seasonsSection = app.cells.staticTexts["Season 5"]
        XCTAssertTrue(seasonsSection.waitForExistence(timeout: 2))
        seasonsSection.tap()

        XCTAssertTrue(app.navigationBars["Season 5"].waitForExistence(timeout: 2))
    }

    func testEpisodesTabNavigationToFavorites() throws {
        // Switch to Episodes tab
        app.tabBars.buttons["Episodes"].tap()

        // Find and tap Favorites
        let favoritesCell = app.cells.staticTexts["Favorites"]
        XCTAssertTrue(favoritesCell.waitForExistence(timeout: 2))
        favoritesCell.tap()

        XCTAssertTrue(app.navigationBars["Favorites"].waitForExistence(timeout: 2))
    }

    // MARK: - Order Tab Navigation

    func testOrderTabNavigationToStartOrder() throws {
        // Switch to Order tab
        app.tabBars.buttons["Order"].tap()

        // Find and tap Start Order
        let startOrderCell = app.cells.staticTexts["Start Order"]
        XCTAssertTrue(startOrderCell.waitForExistence(timeout: 2))
        startOrderCell.tap()

        XCTAssertTrue(app.navigationBars["New Order"].waitForExistence(timeout: 2))
    }

    func testOrderTabNavigationToCart() throws {
        // Switch to Order tab
        app.tabBars.buttons["Order"].tap()

        // Find and tap Cart
        let cartCell = app.cells.staticTexts["Cart"]
        XCTAssertTrue(cartCell.waitForExistence(timeout: 2))
        cartCell.tap()

        XCTAssertTrue(app.navigationBars["Cart"].waitForExistence(timeout: 2))
    }

    func testOrderTabNavigationToHistory() throws {
        // Switch to Order tab
        app.tabBars.buttons["Order"].tap()

        // Find and tap Order History
        let historyCell = app.cells.staticTexts["Order History"]
        XCTAssertTrue(historyCell.waitForExistence(timeout: 2))
        historyCell.tap()

        XCTAssertTrue(app.navigationBars["Order History"].waitForExistence(timeout: 2))
    }
}
