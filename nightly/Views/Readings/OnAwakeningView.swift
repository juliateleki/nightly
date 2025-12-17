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
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

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
                .font(isPad ? .largeTitle.bold() : .title.bold())

            Text("Morning meditation from Alcoholics Anonymous")
                .font(isPad ? .title3 : .subheadline)
                .foregroundStyle(Color.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
    }

    private var readingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading")
                .font(.caption.smallCaps())
                .foregroundStyle(Color.white.opacity(0.78))

            HighlightedOnAwakeningText(text: text)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.14 : 0.20))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .foregroundStyle(.white)
    }
}

// MARK: - Inline Highlighted Text

struct HighlightedOnAwakeningText: View {
    let text: String

    @ScaledMetric(relativeTo: .body) private var bodySize: CGFloat = 17
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

    var body: some View {
        Text(makeAttributedString())
            .lineSpacing(6)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func makeAttributedString() -> AttributedString {
        var attributed = AttributedString(text)
        // Base font for the whole reading
        let base = Font.system(size: isPad ? bodySize + 2 : bodySize)
        attributed.font = base

        // Phrases we want to emphasize
        let phrases: [String] = [
            "Thy will be done",
            "It works - it really does",
            "faith without works is dead"
        ]

        for phrase in phrases {
            if let range = attributed.range(of: phrase, options: [.caseInsensitive]) {
                // Make these stand out more than just bold:
                attributed[range].font = Font.system(size: isPad ? bodySize + 4 : bodySize + 2, weight: .semibold)
                attributed[range].foregroundColor = .white
            }
        }

        return attributed
    }
}
