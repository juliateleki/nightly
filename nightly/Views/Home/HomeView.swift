//
//  HomeView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct HomeView: View {
  @Environment(\.colorScheme) private var colorScheme
  private let quote = DailyQuotes.quote()

  var body: some View {
    ZStack {
      // Background
      LinearGradient(
        colors: [
          Color(.black),
          Color(.systemIndigo).opacity(0.6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 28) {

          // MARK: - App header card
          VStack(alignment: .leading, spacing: 12) {
            HStack {
              VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                  Text("Nightly")
                    .font(.headline.weight(.semibold))
                  Text("🌙")
                }

                Text("One quiet check-in before sleep.")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }

              Spacer()

              HStack(spacing: 8) {
                Circle()
                  .frame(width: 8, height: 8)
                  .foregroundColor(.green)

                Text("Reflecting")
                  .font(.caption.weight(.medium))
              }
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(
                Capsule()
                  .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.12))
              )
            }
          }
          .padding(18)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
              .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.12))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
              .stroke(Color.white.opacity(0.08))
          )

          // MARK: - Quote card (focal point)
          VStack(alignment: .leading, spacing: 14) {
            Text("TONIGHT’S REFLECTION")
              .font(.caption.smallCaps())
              .foregroundColor(.secondary)

            Text("What stood out about today?")
              .font(.title3.weight(.semibold))

            Text("“\(quote.text)”")
              .font(.title3.weight(.semibold))
              .fixedSize(horizontal: false, vertical: true)

            if let author = quote.author, !author.isEmpty {
              Text("— \(author)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Text("Nightly gives you gentle questions to help you slow down, process your day, and capture the moments you don’t want to forget.")
              .font(.footnote)
              .foregroundColor(.secondary)
              .padding(.top, 4)
          }
          .padding(20)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
              .fill(
                LinearGradient(
                  colors: [
                    Color(.systemIndigo).opacity(0.75),
                    Color(.black).opacity(0.9)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
          )
          .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
              .stroke(
                LinearGradient(
                  colors: [
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.08)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 1
              )
          )
          .foregroundColor(.white)

          // MARK: - Recent check-ins (static placeholders for now)
          VStack(spacing: 12) {
            recentRow(label: "Today • 10:34 PM", mood: "Grateful")
            recentRow(label: "Yesterday", mood: "Hopeful")
            recentRow(label: "This week", mood: "Mixed")
          }

          // MARK: - Primary actions
          HStack(spacing: 14) {
            NavigationLink(destination: NewNightlyView()) {
              HStack(spacing: 8) {
                Image(systemName: "pencil.line")
                Text("New entry")
                  .fontWeight(.semibold)
              }
              .padding(.horizontal, 22)
              .padding(.vertical, 14)
              .frame(maxWidth: .infinity)
              .background(
                Capsule()
                  .fill(
                    LinearGradient(
                      colors: [
                        Color(.systemPurple),
                        Color(.systemPink)
                      ],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )
              )
              .foregroundColor(.white)
            }

            NavigationLink(destination: HistoryView()) {
              HStack(spacing: 8) {
                Image(systemName: "book.closed")
                Text("History")
              }
              .padding(.horizontal, 22)
              .padding(.vertical, 14)
              .frame(maxWidth: .infinity)
              .background(
                Capsule()
                  .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.10))
              )
              .overlay(
                Capsule()
                  .stroke(Color.white.opacity(0.12), lineWidth: 1)
              )
              .foregroundColor(.primary)
            }
          }

          // MARK: - Privacy note
          HStack(spacing: 8) {
            Image(systemName: "lock.fill")
              .font(.caption)
            Text("Private & stored on this device only.")
              .font(.caption)
              .foregroundColor(.secondary)
          }
          .padding(.top, 4)
          .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 32)
      }
    }
  }

  // MARK: - Helpers

  private func recentRow(label: String, mood: String) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.subheadline)
        Text(mood)
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      HStack(spacing: 6) {
        Circle()
          .frame(width: 8, height: 8)
        Text(mood)
          .font(.caption.weight(.medium))
      }
      .foregroundColor(.secondary)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .fill(Color.white.opacity(0.05))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .stroke(Color.white.opacity(0.06), lineWidth: 1)
    )
  }
}

#Preview {
  NavigationStack {
    HomeView()
  }
}
