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
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

    private let quote = DailyQuotes.quote()

    // MARK: - Helper type for mood display
    private struct MoodSummary {
        let label: String
        let emoji: String
    }

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

    private var thisWeekEntries: [NightlyEntry] {
        let cal = Calendar.current
        let now = Date()
        let currentWeek = cal.component(.weekOfYear, from: now)
        let currentYear = cal.component(.yearForWeekOfYear, from: now)

        return store.entries.filter { entry in
            let d = entry.date
            let week = cal.component(.weekOfYear, from: d)
            let year = cal.component(.yearForWeekOfYear, from: d)
            return week == currentWeek && year == currentYear
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

    // MARK: - Weekly Mood Summary Logic (new)

    private func weeklyMoodSummary(for entries: [NightlyEntry]) -> MoodSummary? {
        guard !entries.isEmpty else { return nil }

        let moods = entries.map { $0.mood.label.lowercased() }

        // Define positive and negative mood buckets
        let goodSet = Set(["good", "very good"])
        let badSet  = Set(["bad", "very bad"])

        let hasGood = moods.contains(where: { goodSet.contains($0) })
        let hasBad  = moods.contains(where: { badSet.contains($0) })

        // If both good-ish and bad-ish moods appear → Mixed
        if hasGood && hasBad {
            return MoodSummary(label: "Mixed", emoji: "🌓")
        }

        // Only good moods appear
        if hasGood {
            if moods.contains("very good") {
                return MoodSummary(label: "Very Good", emoji: "🌕")
            } else {
                return MoodSummary(label: "Good", emoji: "🌔")
            }
        }

        // Only bad moods appear
        if hasBad {
            if moods.contains("very bad") {
                return MoodSummary(label: "Very Bad", emoji: "🌑")
            } else {
                return MoodSummary(label: "Bad", emoji: "🌘")
            }
        }

        // Fallback — if unrecognized moods exist, pick the most frequent
        let freq = Dictionary(grouping: entries.map { $0.mood }, by: { $0.label })
        if let (label, group) = freq.max(by: { $0.value.count < $1.value.count }) {
            return MoodSummary(label: label, emoji: group.first?.emoji ?? "🙂")
        }

        return nil
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
                    headerCard

                    // MARK: - Quote card
                    quoteCard

                    // MARK: - Recent entries
                    VStack(spacing: 12) {
                        recentEntryRow(title: "Today", entry: todayEntry)
                        recentEntryRow(title: "Yesterday", entry: yesterdayEntry)
                        weeklySummaryRow(title: "This week", entries: thisWeekEntries)
                    }

                    // MARK: - Actions
                    actionButtons

                    // MARK: - Privacy message
                    privacyNote
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
    }

    // MARK: - UI Sections

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Nightly")
                            .font((isPad ? Font.title3 : Font.headline).weight(.semibold))
                        Text("🌙")
                    }

                    Text("One quiet check-in before sleep.")
                        .font(isPad ? .callout : .subheadline)
                        .foregroundStyle(Color.white.opacity(0.78))
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
                        .fill(Color.white.opacity(0.14))
                )
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.white.opacity(0.14))
        )
        .foregroundStyle(.white)
    }

    private var quoteCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TONIGHT’S REFLECTION")
                .font(.caption.smallCaps())
                .foregroundStyle(Color.white.opacity(0.78))

            Text("“\(quote.text)”")
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)

            if let author = quote.author, !author.isEmpty {
                Text("— \(author)")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.78))
            }

            Text("Nightly gives you gentle questions to help you slow down, process your day, and capture the moments you don’t want to forget.")
                .font(.footnote)
                .foregroundStyle(Color.white.opacity(0.78))
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
    }

    // MARK: - Row Builders

    private func recentEntryRow(title: String, entry: NightlyEntry?) -> some View {
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
                .fill(Color.white.opacity(0.11))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    private func weeklySummaryRow(title: String, entries: [NightlyEntry]) -> some View {
        let summary = weeklyMoodSummary(for: entries)

        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)

                if summary != nil {
                    Text("Average mood this week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("No entries yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if let summary = summary {
                HStack(spacing: 6) {
                    Text(summary.emoji)
                    Text(summary.label)
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
                .fill(Color.white.opacity(0.11))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    // MARK: - Buttons & Footer

    private var actionButtons: some View {
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
                        .fill(Color.white.opacity(0.12))
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
                .foregroundColor(.white)
            }
        }
    }

    private var privacyNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.caption)
            Text("Private & stored on this device only.")
                .font(.caption)
                .foregroundStyle(Color.white.opacity(0.70))
        }
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(NightlyStore())
    }
}
