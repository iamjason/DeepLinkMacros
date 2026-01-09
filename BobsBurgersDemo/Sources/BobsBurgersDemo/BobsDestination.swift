//
//  BobsDestination.swift
//  BobsBurgersDemo
//
//  Tab-specific deep link destinations using CasePathable + DeepLinkMacros.
//  Each tab has its own destination enum for type-safe navigation.
//

import CasePaths
import DeepLinkRouting

// MARK: - Menu Tab Destinations

/// Destinations for the Menu tab - browse burgers and specials.
@CasePathable
@DeepLinkDestination
public enum MenuDestination: Hashable, Sendable {

    /// The main menu listing
    /// URL: /menu
    @DeepLinkRoute("/menu")
    case list

    /// A specific burger's detail page
    /// URL: /menu/burger/:id
    @DeepLinkRoute("/menu/burger/:id")
    case burgerDetail(id: Int)

    /// The famous burger of the day
    /// URL: /menu/burger-of-the-day
    @DeepLinkRoute("/menu/burger-of-the-day")
    case burgerOfTheDay

    /// Sides menu
    /// URL: /menu/sides
    @DeepLinkRoute("/menu/sides")
    case sides

    /// Drinks menu
    /// URL: /menu/drinks
    @DeepLinkRoute("/menu/drinks")
    case drinks
}

// MARK: - Family Tab Destinations

/// Destinations for the Family tab - meet the Belchers and friends.
@CasePathable
@DeepLinkDestination
public enum FamilyDestination: Hashable, Sendable {

    /// Family overview
    /// URL: /family
    @DeepLinkRoute("/family")
    case list

    /// Individual family member profile
    /// URL: /family/member/:name
    @DeepLinkRoute("/family/member/:name")
    case member(name: String)

    /// Friends of the family
    /// URL: /family/friends
    @DeepLinkRoute("/family/friends")
    case friends

    /// A specific friend's profile
    /// URL: /family/friends/:name
    @DeepLinkRoute("/family/friends/:name")
    case friend(name: String)

    /// The restaurant staff
    /// URL: /family/staff
    @DeepLinkRoute("/family/staff")
    case staff
}

// MARK: - Episodes Tab Destinations

/// Destinations for the Episodes tab - watch and browse episodes.
@CasePathable
@DeepLinkDestination
public enum EpisodesDestination: Hashable, Sendable {

    /// All seasons overview
    /// URL: /episodes
    @DeepLinkRoute("/episodes")
    case list

    /// Browse a specific season
    /// URL: /episodes/season/:number
    @DeepLinkRoute("/episodes/season/:number")
    case season(number: Int)

    /// Watch a specific episode
    /// URL: /episodes/:season/:episode
    @DeepLinkRoute("/episodes/:season/:episode")
    case episode(season: Int, episode: Int)

    /// Search episodes
    /// URL: /episodes/search?q=QUERY
    @DeepLinkRoute("/episodes/search", query: ["q"])
    case search(q: String?)

    /// Favorite episodes
    /// URL: /episodes/favorites
    @DeepLinkRoute("/episodes/favorites")
    case favorites
}

// MARK: - Order Tab Destinations

/// Destinations for the Order tab - place and track orders.
@CasePathable
@DeepLinkDestination
public enum OrderDestination: Hashable, Sendable {

    /// Start a new order
    /// URL: /order
    @DeepLinkRoute("/order")
    case new

    /// Order with promo code
    /// URL: /order/promo/:code
    @DeepLinkRoute("/order/promo/:code")
    case withPromo(code: String)

    /// View cart
    /// URL: /order/cart
    @DeepLinkRoute("/order/cart")
    case cart

    /// Track an existing order
    /// URL: /order/track/:orderId
    @DeepLinkRoute("/order/track/:orderId")
    case track(orderId: String)

    /// Order history
    /// URL: /order/history
    @DeepLinkRoute("/order/history")
    case history
}

// MARK: - App Tab Enum

/// The main tabs of the app - also CasePathable for ergonomic tab switching.
@CasePathable
public enum AppTab: Hashable, Sendable, CaseIterable {
    case menu
    case family
    case episodes
    case order

    public var title: String {
        switch self {
        case .menu: "Menu"
        case .family: "Family"
        case .episodes: "Episodes"
        case .order: "Order"
        }
    }

    public var icon: String {
        switch self {
        case .menu: "menucard"
        case .family: "person.3"
        case .episodes: "tv"
        case .order: "cart"
        }
    }

    public var selectedIcon: String {
        switch self {
        case .menu: "menucard.fill"
        case .family: "person.3.fill"
        case .episodes: "tv.fill"
        case .order: "cart.fill"
        }
    }
}
