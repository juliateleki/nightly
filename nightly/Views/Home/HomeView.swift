//
//  NightlyDetailView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct HomeView: View {
  private let quote = DailyQuotes.quote()
  private let verticalBias: CGFloat = 80   // moves quote slightly upward

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
          // "Welcome" at the top
          Text("Welcome")
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)

          Spacer(minLength: 0)

          // Centered quote — no background box
          VStack(alignment: .center, spacing: 12) {
            Image(systemName: "quote.bubble")
              .imageScale(.large)
              .opacity(0.6)

            Text("“\(quote.text)”")
              .font(.title)
              .multilineTextAlignment(.center)
              .fixedSize(horizontal: false, vertical: true)

            if let author = quote.author, !author.isEmpty {
              Text("— \(author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
          }
          .frame(maxWidth: 560)
          .frame(maxWidth: .infinity, alignment: .center)

          Spacer(minLength: 0)
          Color.clear.frame(height: verticalBias)
        }
        .padding()
        .frame(minHeight: proxy.size.height)
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        ShareLink(item: shareText) { Image(systemName: "square.and.arrow.up") }
          .accessibilityLabel("Share Quote")
      }
    }
  }

  private var shareText: String {
    if let author = quote.author, !author.isEmpty {
      return "“\(quote.text)” — \(author)"
    }
    return "“\(quote.text)”"
  }
}

#Preview {
  NavigationStack { HomeView() }
}
