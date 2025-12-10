//
//  OnAwakeningView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//  Updated styling with gradient background + card layout + inline highlights
//

import SwiftUI

struct OnAwakeningView: View {
    @Environment(\.colorScheme) private var colorScheme

    private let text = OnAwakening.text

    var body: some View {
        ZStack {
            // Background to match Nightly's main screens
            LinearGradient(
                colors: [
                    Color(.black),
                    Color(.systemIndigo).opacity(0.65)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    readingCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: text) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share On Awakening")
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("On Awakening")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Morning meditation from Alcoholics Anonymous")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var readingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading")
                .font(.caption.smallCaps())
                .foregroundStyle(.secondary)

            HighlightedOnAwakeningText(text: text)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

// MARK: - Inline Highlighted Text

struct HighlightedOnAwakeningText: View {
    let text: String

    var body: some View {
        Text(makeAttributedString())
            .lineSpacing(6)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func makeAttributedString() -> AttributedString {
        var attributed = AttributedString(text)
        // Base font for the whole reading
        attributed.font = .body

        // Phrases we want to emphasize
        let phrases: [String] = [
            "Thy will be done",
            "It works - it really does",
            "faith without works is dead"
        ]

        for phrase in phrases {
            if let range = attributed.range(of: phrase, options: [.caseInsensitive]) {
                // Make these stand out more than just bold:
                attributed[range].font = .headline.bold()
                attributed[range].foregroundColor = .accentColor
            }
        }

        return attributed
    }
}
