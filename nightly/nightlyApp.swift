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
  @State private var showSplash = true

  var body: some Scene {
    WindowGroup {
      ZStack {
        ContentView()
          .environmentObject(store)
          .tint(Color("AccentColor"))

        if showSplash {
          SplashOverlay(isVisible: $showSplash)
        }
      }
    }
  }
}
