//
//  SerenityPrayerView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct SerenityPrayerView: View {
  private let prayer = SerenityPrayer.text

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Serenity Prayer").font(.title2.weight(.semibold))
        Text(prayer)
          .font(.body)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding()
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        ShareLink(item: prayer) { Image(systemName: "square.and.arrow.up") }
          .accessibilityLabel("Share")
      }
    }
  }
}
