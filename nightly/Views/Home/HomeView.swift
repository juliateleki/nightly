//
//  HomeView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject private var store: NightlyStore
  @Environment(\.colorScheme) private var colorScheme

  private let quote = DailyQuotes.quote()

  // MARK: - Date helpers

  private static let timeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .none
    df.timeStyle = .short
    return df
  }()

  private var todayEntry: NightlyEntry? {
    latestEntry { Calendar.current.isDateInToday($0.date) }
  }

  private var yesterdayEntry: NightlyEntry? {
    latestEntry { Calendar.current.isDateInYesterday($0.date) }
  }

  private var thisWeekEntry: NightlyEntry? {
    let cal = Calendar.current
    let now = Date()
    let currentWeek = cal.component(.weekOfYear, from: now)
    let currentYear = cal.component(.yearForWeekOfYear, from: now)

    return latestEntry { entry in
      let d = entry.date
      let week = cal.component(.weekOfYear, from: d)
      let year = cal.component(.yearForWeekOfYear, from: d)
      return week == currentWeek
        && year == currentYear
        && !cal.isDateInToday(d)
        && !cal.isDateInYesterday(d)
    }
  }

  private func latestEntry(where predicate: (NightlyEntry) -> Bool) -> NightlyEntry? {
    store.entries
      .filter(predicate)
      .sorted { $0.date > $1.date }
      .first
  }

  private func timeString(for date: Date) -> String {
    Self.timeFormatter.string(from: date)
  }

  // MARK: - Body

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

          // MARK: - Quote card (focal point, no “What stood out…”)
          VStack(alignment: .leading, spacing: 14) {
            Text("TONIGHT’S REFLECTION")
              .font(.caption.smallCaps())
              .foregroundColor(.secondary)

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

          // MARK: - Recent mood check-ins (real data + placeholders)
          VStack(spacing: 12) {
            recentRow(title: "Today", entry: todayEntry)
            recentRow(title: "Yesterday", entry: yesterdayEntry)
            recentRow(title: "This week", entry: thisWeekEntry)
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

  // MARK: - Recent row helper

  private func recentRow(title: String, entry: NightlyEntry?) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        if let entry = entry {
          Text("\(title) • \(timeString(for: entry.date))")
            .font(.subheadline)
          Text("Captured with Nightly")
            .font(.caption)
            .foregroundColor(.secondary)
        } else {
          Text(title)
            .font(.subheadline)
          Text("No entry yet")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }

      Spacer()

      if let entry = entry {
        HStack(spacing: 6) {
          Text(entry.mood.emoji)
          Text(entry.mood.label)
            .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
          Capsule()
            .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.12))
        )
      } else {
        Text("—")
          .font(.caption)
          .foregroundColor(.secondary)
      }
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
      .environmentObject(NightlyStore())
  }
}
