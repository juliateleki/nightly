//
//  HomeView.swift
//  nightly
//
//  Created by Julia Teleki on 9/20/25.
//

import SwiftUI

struct HomeView: View {
  private let quote = DailyQuotes.quote()

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text("Welcome to Nightly")
          .font(.largeTitle.bold())
          .frame(maxWidth: .infinity, alignment: .leading)

        VStack(alignment: .leading, spacing: 12) {
          Image(systemName: "quote.bubble")
            .imageScale(.large)
            .opacity(0.6)

          Text("“\(quote.text)”")
            .font(.title3)
            .fixedSize(horizontal: false, vertical: true)

          if let author = quote.author, !author.isEmpty {
            Text("— \(author)")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
        .padding(16)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(Color(.secondarySystemBackground))
        )

        Spacer(minLength: 8)
      }
      .padding()
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        ShareLink(item: shareText) {
          Image(systemName: "square.and.arrow.up")
        }
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
  NavigationStack { HomeView().navigationTitle("") }
}
