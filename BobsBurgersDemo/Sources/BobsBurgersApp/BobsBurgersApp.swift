//
//  BobsBurgersApp.swift
//  BobsBurgersDemo
//
//  Multi-tabbed iOS app demonstrating DeepLinkMacros + CasePathable.
//

import SwiftUI
import BobsBurgersDemo

@main
struct BobsBurgersApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(router)
                .onOpenURL { url in
                    router.handleDeepLink(url)
                }
        }
    }
}
