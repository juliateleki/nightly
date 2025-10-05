//
//  nightlyApp.swift
//  nightly
//
//  Created by Julia Teleki on 8/22/25.
//

import SwiftUI


@main
struct NightlyApp: App {
@StateObject private var store = NightlyStore()


var body: some Scene {
  WindowGroup {
    ContentView()
    .environmentObject(store)
    }
  }
}
