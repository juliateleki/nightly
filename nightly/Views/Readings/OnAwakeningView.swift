//
//  OnAwakeningView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct OnAwakeningView: View {
  private let text = OnAwakening.text

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("On Awakening").font(.title2.weight(.semibold))
        Text(text)
          .font(.body)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding()
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        ShareLink(item: text) { Image(systemName: "square.and.arrow.up") }
          .accessibilityLabel("Share")
      }
    }
  }
}
