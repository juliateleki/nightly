//
//  SerenityPrayerView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//  Updated styling with gradient background + card layout
//

import SwiftUI

struct SerenityPrayerView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad

    private let prayer = SerenityPrayer.text

    var body: some View {
        ZStack {
            // Background to feel consistent with Sobriety Counter
            LinearGradient(
                colors: [
                    Color(.black),
                    Color(.systemTeal).opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header
                    prayerCard
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: prayer) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share Serenity Prayer")
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Serenity Prayer")
                .font(isPad ? .largeTitle.bold() : .title.bold())

            Text("A short prayer for acceptance, courage, and wisdom")
                .font(isPad ? .title3 : .subheadline)
                .foregroundStyle(Color.white.opacity(0.78))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
    }

    private var prayerCard: some View {
        VStack(alignment: .center, spacing: 18) {
            Text(prayer)
                .font(isPad ? .title2.weight(.semibold) : .title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .textSelection(.enabled)

            Divider()
                .overlay(Color.white.opacity(0.15))

            Text("Take a breath, read slowly, and let the words land.")
                .font(.footnote)
                .foregroundStyle(Color.white.opacity(0.78))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
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
