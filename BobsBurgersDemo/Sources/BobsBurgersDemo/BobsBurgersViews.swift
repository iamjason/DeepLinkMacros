//
//  BobsBurgersViews.swift
//  BobsBurgersDemo
//
//  SwiftUI views for the multi-tabbed Bob's Burgers app.
//

import SwiftUI
import CasePaths
import DeepLinkRouting

// MARK: - App Router

/// Handles deep link routing across all tabs.
@Observable
public final class AppRouter {
    // Tab-specific routers
    private let menuRouter = DeepLinkRouter<MenuDestination>()
    private let familyRouter = DeepLinkRouter<FamilyDestination>()
    private let episodesRouter = DeepLinkRouter<EpisodesDestination>()
    private let orderRouter = DeepLinkRouter<OrderDestination>()

    // Current tab and navigation state
    public var selectedTab: AppTab = .menu
    public var menuPath = NavigationPath()
    public var familyPath = NavigationPath()
    public var episodesPath = NavigationPath()
    public var orderPath = NavigationPath()

    // Last handled deep link (for debugging)
    public var lastDeepLink: String?

    public init() {}

    /// Handle an incoming deep link URL
    public func handleDeepLink(_ url: URL) {
        handleDeepLink(url.path + (url.query.map { "?\($0)" } ?? ""))
    }

    /// Handle a deep link path string
    public func handleDeepLink(_ path: String) {
        lastDeepLink = path

        // Try each router in order
        if let dest = menuRouter.match(path) {
            selectedTab = .menu
            menuPath = NavigationPath()
            menuPath.append(dest)
        } else if let dest = familyRouter.match(path) {
            selectedTab = .family
            familyPath = NavigationPath()
            familyPath.append(dest)
        } else if let dest = episodesRouter.match(path) {
            selectedTab = .episodes
            episodesPath = NavigationPath()
            episodesPath.append(dest)
        } else if let dest = orderRouter.match(path) {
            selectedTab = .order
            orderPath = NavigationPath()
            orderPath.append(dest)
        }
    }

    /// All registered routes for display
    public var allRoutes: [(tab: String, pattern: String)] {
        var routes: [(String, String)] = []
        routes += menuRouter.routes.map { ("Menu", $0.pattern) }
        routes += familyRouter.routes.map { ("Family", $0.pattern) }
        routes += episodesRouter.routes.map { ("Episodes", $0.pattern) }
        routes += orderRouter.routes.map { ("Order", $0.pattern) }
        return routes
    }
}

// MARK: - Root Tab View

public struct RootTabView: View {
    @Environment(AppRouter.self) private var router

    public init() {}

    public var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            MenuTab()
                .tabItem {
                    Label(AppTab.menu.title, systemImage: AppTab.menu.icon)
                }
                .tag(AppTab.menu)

            FamilyTab()
                .tabItem {
                    Label(AppTab.family.title, systemImage: AppTab.family.icon)
                }
                .tag(AppTab.family)

            EpisodesTab()
                .tabItem {
                    Label(AppTab.episodes.title, systemImage: AppTab.episodes.icon)
                }
                .tag(AppTab.episodes)

            OrderTab()
                .tabItem {
                    Label(AppTab.order.title, systemImage: AppTab.order.icon)
                }
                .tag(AppTab.order)
        }
        .tint(.red)
    }
}

// MARK: - Menu Tab

struct MenuTab: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.menuPath) {
            MenuListView()
                .navigationDestination(for: MenuDestination.self) { dest in
                    MenuDestinationView(destination: dest)
                }
        }
    }
}

struct MenuListView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        List {
            Section("Specials") {
                NavigationLink(value: MenuDestination.burgerOfTheDay) {
                    Label("Burger of the Day", systemImage: "star.fill")
                        .foregroundStyle(.orange)
                }
            }

            Section("Menu") {
                NavigationLink(value: MenuDestination.list) {
                    Label("All Burgers", systemImage: "menucard")
                }
                NavigationLink(value: MenuDestination.sides) {
                    Label("Sides", systemImage: "fries")
                }
                NavigationLink(value: MenuDestination.drinks) {
                    Label("Drinks", systemImage: "cup.and.saucer")
                }
            }

            Section("Featured Burgers") {
                ForEach([1, 7, 13, 42], id: \.self) { id in
                    NavigationLink(value: MenuDestination.burgerDetail(id: id)) {
                        Label("Burger #\(id)", systemImage: "fork.knife")
                    }
                }
            }

            DeepLinkTestSection()
        }
        .navigationTitle("Menu")
        .toolbar {
            ToolbarItem(placement: .principal) {
                HeaderLogo()
            }
        }
    }
}

struct MenuDestinationView: View {
    let destination: MenuDestination

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: destination.icon)
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            Text(destination.title)
                .font(.largeTitle.bold())

            Text(destination.subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle(destination.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Family Tab

struct FamilyTab: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.familyPath) {
            FamilyListView()
                .navigationDestination(for: FamilyDestination.self) { dest in
                    FamilyDestinationView(destination: dest)
                }
        }
    }
}

struct FamilyListView: View {
    var body: some View {
        List {
            Section("The Belchers") {
                ForEach(["Bob", "Linda", "Tina", "Gene", "Louise"], id: \.self) { name in
                    NavigationLink(value: FamilyDestination.member(name: name.lowercased())) {
                        Label(name, systemImage: "person.fill")
                    }
                }
            }

            Section("More") {
                NavigationLink(value: FamilyDestination.friends) {
                    Label("Friends", systemImage: "person.2")
                }
                NavigationLink(value: FamilyDestination.staff) {
                    Label("Restaurant Staff", systemImage: "person.badge.clock")
                }
            }

            Section("Friends") {
                ForEach(["Teddy", "Mort", "Regular Sized Rudy"], id: \.self) { name in
                    NavigationLink(value: FamilyDestination.friend(name: name.lowercased().replacingOccurrences(of: " ", with: "-"))) {
                        Label(name, systemImage: "person")
                    }
                }
            }

            DeepLinkTestSection()
        }
        .navigationTitle("Family")
    }
}

struct FamilyDestinationView: View {
    let destination: FamilyDestination

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: destination.icon)
                .font(.system(size: 80))
                .foregroundStyle(.blue)

            Text(destination.title)
                .font(.largeTitle.bold())

            Text(destination.subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle(destination.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Episodes Tab

struct EpisodesTab: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.episodesPath) {
            EpisodesListView()
                .navigationDestination(for: EpisodesDestination.self) { dest in
                    EpisodesDestinationView(destination: dest)
                }
        }
    }
}

struct EpisodesListView: View {
    var body: some View {
        List {
            Section("Browse") {
                NavigationLink(value: EpisodesDestination.list) {
                    Label("All Seasons", systemImage: "square.grid.3x3")
                }
                NavigationLink(value: EpisodesDestination.favorites) {
                    Label("Favorites", systemImage: "heart.fill")
                }
                NavigationLink(value: EpisodesDestination.search(q: nil)) {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }

            Section("Seasons") {
                ForEach(1...14, id: \.self) { season in
                    NavigationLink(value: EpisodesDestination.season(number: season)) {
                        Label("Season \(season)", systemImage: "tv")
                    }
                }
            }

            Section("Popular Episodes") {
                NavigationLink(value: EpisodesDestination.episode(season: 3, episode: 1)) {
                    Label("S3E1 - Ear-sy Rider", systemImage: "play.circle")
                }
                NavigationLink(value: EpisodesDestination.episode(season: 4, episode: 12)) {
                    Label("S4E12 - The Frond Files", systemImage: "play.circle")
                }
            }

            DeepLinkTestSection()
        }
        .navigationTitle("Episodes")
    }
}

struct EpisodesDestinationView: View {
    let destination: EpisodesDestination

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: destination.icon)
                .font(.system(size: 80))
                .foregroundStyle(.purple)

            Text(destination.title)
                .font(.largeTitle.bold())

            Text(destination.subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle(destination.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Order Tab

struct OrderTab: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.orderPath) {
            OrderListView()
                .navigationDestination(for: OrderDestination.self) { dest in
                    OrderDestinationView(destination: dest)
                }
        }
    }
}

struct OrderListView: View {
    var body: some View {
        List {
            Section("New Order") {
                NavigationLink(value: OrderDestination.new) {
                    Label("Start Order", systemImage: "plus.circle")
                }
                NavigationLink(value: OrderDestination.withPromo(code: "BURGERLOVER")) {
                    Label("Use Promo Code", systemImage: "tag")
                }
            }

            Section("Your Orders") {
                NavigationLink(value: OrderDestination.cart) {
                    Label("Cart", systemImage: "cart")
                }
                NavigationLink(value: OrderDestination.history) {
                    Label("Order History", systemImage: "clock.arrow.circlepath")
                }
            }

            Section("Track Order") {
                NavigationLink(value: OrderDestination.track(orderId: "ORD-12345")) {
                    Label("Track #ORD-12345", systemImage: "shippingbox")
                }
            }

            DeepLinkTestSection()
        }
        .navigationTitle("Order")
    }
}

struct OrderDestinationView: View {
    let destination: OrderDestination

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: destination.icon)
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text(destination.title)
                .font(.largeTitle.bold())

            Text(destination.subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle(destination.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - Deep Link Test Section

struct DeepLinkTestSection: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        Section("Test Deep Links") {
            ForEach(TestLinks.samples.prefix(5), id: \.path) { link in
                Button {
                    router.handleDeepLink(link.path)
                } label: {
                    VStack(alignment: .leading) {
                        Text(link.title)
                            .font(.headline)
                        Text(link.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontDesign(.monospaced)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Header Logo

struct HeaderLogo: View {
    var body: some View {
        Text("BOB'S BURGERS")
            .font(.headline)
            .fontWeight(.black)
            .foregroundStyle(.red)
    }
}

// MARK: - Test Links

public enum TestLinks {
    public struct Link: Sendable {
        public let title: String
        public let path: String
    }

    public static let samples: [Link] = [
        // Menu
        Link(title: "Burger of the Day", path: "/menu/burger-of-the-day"),
        Link(title: "Burger #42", path: "/menu/burger/42"),
        Link(title: "Sides", path: "/menu/sides"),

        // Family
        Link(title: "Tina's Profile", path: "/family/member/tina"),
        Link(title: "Louise's Profile", path: "/family/member/louise"),
        Link(title: "Friends", path: "/family/friends"),
        Link(title: "Teddy", path: "/family/friends/teddy"),

        // Episodes
        Link(title: "Season 5", path: "/episodes/season/5"),
        Link(title: "S3E12", path: "/episodes/3/12"),
        Link(title: "Search", path: "/episodes/search?q=burger"),
        Link(title: "Favorites", path: "/episodes/favorites"),

        // Order
        Link(title: "New Order", path: "/order"),
        Link(title: "Promo Code", path: "/order/promo/FREEFRIES"),
        Link(title: "Track Order", path: "/order/track/ORD-98765"),
        Link(title: "Cart", path: "/order/cart"),
    ]
}

// MARK: - Destination Extensions

extension MenuDestination {
    var title: String {
        switch self {
        case .list: "All Burgers"
        case .burgerDetail(let id): "Burger #\(id)"
        case .burgerOfTheDay: "Burger of the Day"
        case .sides: "Sides"
        case .drinks: "Drinks"
        }
    }

    var subtitle: String {
        switch self {
        case .list: "Browse our full menu of handcrafted burgers"
        case .burgerDetail(let id): "Burger #\(id) - One of Bob's finest creations!"
        case .burgerOfTheDay: "The 'Poutine on the Ritz' Burger - A Canadian-inspired masterpiece!"
        case .sides: "Fries, onion rings, and more"
        case .drinks: "Sodas, shakes, and refreshments"
        }
    }

    var icon: String {
        switch self {
        case .list: "menucard.fill"
        case .burgerDetail: "fork.knife"
        case .burgerOfTheDay: "star.fill"
        case .sides: "leaf"
        case .drinks: "cup.and.saucer.fill"
        }
    }
}

extension FamilyDestination {
    var title: String {
        switch self {
        case .list: "The Belchers"
        case .member(let name): name.capitalized
        case .friends: "Friends"
        case .friend(let name): name.capitalized.replacingOccurrences(of: "-", with: " ")
        case .staff: "Staff"
        }
    }

    var subtitle: String {
        switch self {
        case .list: "Meet the Belcher family!"
        case .member(let name): familyQuote(name)
        case .friends: "Friends of the Belcher family"
        case .friend(let name): friendQuote(name)
        case .staff: "The hardworking staff at Bob's Burgers"
        }
    }

    var icon: String {
        switch self {
        case .list: "person.3.fill"
        case .member: "person.fill"
        case .friends: "person.2.fill"
        case .friend: "person.fill"
        case .staff: "person.badge.clock.fill"
        }
    }

    private func familyQuote(_ name: String) -> String {
        let quotes: [String: String] = [
            "bob": "\"I love you all, but you're all terrible.\"",
            "linda": "\"Alriiiight!\"",
            "tina": "\"Uhhhhhhhhh...\"",
            "gene": "\"This is me now!\"",
            "louise": "\"Let's get weird!\""
        ]
        return quotes[name.lowercased()] ?? "A member of the Belcher family"
    }

    private func friendQuote(_ name: String) -> String {
        let quotes: [String: String] = [
            "teddy": "\"I'm Teddy, I'm a handyman!\"",
            "mort": "\"Business has been dead... literally.\"",
            "regular-sized-rudy": "\"I'm Regular Sized Rudy!\""
        ]
        return quotes[name.lowercased()] ?? "A friend of the family"
    }
}

extension EpisodesDestination {
    var title: String {
        switch self {
        case .list: "All Seasons"
        case .season(let number): "Season \(number)"
        case .episode(let season, let episode): "S\(season)E\(episode)"
        case .search(let q): q.map { "Search: \($0)" } ?? "Search"
        case .favorites: "Favorites"
        }
    }

    var subtitle: String {
        switch self {
        case .list: "Browse all seasons of Bob's Burgers"
        case .season(let number): "All episodes from Season \(number)"
        case .episode(let season, let episode): "Now playing: Season \(season), Episode \(episode)"
        case .search(let q): q.map { "Results for '\($0)'" } ?? "Search for episodes"
        case .favorites: "Your favorite episodes"
        }
    }

    var icon: String {
        switch self {
        case .list: "square.grid.3x3.fill"
        case .season: "tv.fill"
        case .episode: "play.tv.fill"
        case .search: "magnifyingglass"
        case .favorites: "heart.fill"
        }
    }
}

extension OrderDestination {
    var title: String {
        switch self {
        case .new: "New Order"
        case .withPromo(let code): "Promo: \(code)"
        case .cart: "Cart"
        case .track(let orderId): "Order \(orderId)"
        case .history: "Order History"
        }
    }

    var subtitle: String {
        switch self {
        case .new: "Start a fresh order from Bob's Burgers"
        case .withPromo(let code): "Order with promo code: \(code)"
        case .cart: "Review your cart before checkout"
        case .track(let orderId): "Tracking order \(orderId)"
        case .history: "View your past orders"
        }
    }

    var icon: String {
        switch self {
        case .new: "plus.circle.fill"
        case .withPromo: "tag.fill"
        case .cart: "cart.fill"
        case .track: "shippingbox.fill"
        case .history: "clock.arrow.circlepath"
        }
    }
}
