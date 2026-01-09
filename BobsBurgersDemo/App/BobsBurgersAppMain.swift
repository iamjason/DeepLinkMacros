//
//  BobsBurgersAppMain.swift
//  BobsBurgersDemo
//
//  Xcode project wrapper that imports the Swift Package module.
//

import SwiftUI
import BobsBurgersDemo

@main
struct BobsBurgersAppMain: App {
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
