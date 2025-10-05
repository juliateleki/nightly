//
//  SplashOverlay.swift
//  nightly
//
//  Created by Julia Teleki on 10/5/25.
//
import SwiftUI

struct SplashOverlay: View {
  @Binding var isVisible: Bool
  @State private var opacity: Double = 1.0

  var body: some View {
    ZStack {
      // Full-screen splash art
      Image("LaunchMoonSplash")
        .resizable()
        .scaledToFill()
        .ignoresSafeArea()        // cover entire screen
        .opacity(opacity)
        .onAppear {
          Task {
            // Hold a bit longer, then fade more slowly
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s hold
            withAnimation(.easeOut(duration: 1.2)) {
              opacity = 0.0
            }
            try? await Task.sleep(nanoseconds: 1_300_000_000) // wait for fade
            isVisible = false
          }
        }
    }
    .allowsHitTesting(false)
    .transition(.opacity)
    .zIndex(1)
  }
}
