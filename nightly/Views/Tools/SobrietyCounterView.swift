//
//  SobrietyCounterView.swift
//  nightly
//

import SwiftUI

struct SobrietyCounterView: View {
    @AppStorage("sobrietyStart_ts") private var sobrietyStartTS: Double = 0
    @State private var showingPicker = false
    @State private var tempDate: Date = Date()

    @Environment(\.colorScheme) private var colorScheme

    // Animation state
    @State private var coinScale: CGFloat = 1.0
    @State private var coinRotation: Double = 0
    @State private var coinGlowPhase: Double = 0
    @State private var glowStarted: Bool = false

    // MARK: - Dates & intervals

    private var sobrietyStart: Date? {
        sobrietyStartTS > 0 ? Date(timeIntervalSince1970: sobrietyStartTS) : nil
    }

    private var now: Date { Date() }

    private var isValidSobriety: Bool {
        if let start = sobrietyStart {
            return start <= now
        }
        return false
    }

    private var totalSeconds: Int {
        guard let start = sobrietyStart, isValidSobriety else { return 0 }
        let interval = max(0, now.timeIntervalSince(start))
        return Int(interval.rounded())
    }

    private var totalDays: Int {
        totalSeconds / (60 * 60 * 24)
    }

    private var totalHours: Int {
        totalSeconds / (60 * 60)
    }

    private var totalMonthsInt: Int {
        guard let start = sobrietyStart, isValidSobriety else { return 0 }
        let comps = Calendar.current.dateComponents([.month], from: start, to: now)
        return max(0, comps.month ?? 0)
    }

    private var totalYearsInt: Int {
        totalMonthsInt / 12
    }

    private var totalMonthsApprox: Double {
        guard isValidSobriety else { return 0 }
        let days = Double(totalDays)
        return days / 30.4
    }

    private var sobrietyStartFormatted: String {
        guard let start = sobrietyStart else { return "Not set yet" }
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: start)
    }

    // MARK: - Chip image name (uses your filenames)

    /// Chooses the chip asset name based on months / years,
    /// using your actual filenames and milestone chips.
    private var chipImageName: String? {
        guard isValidSobriety else { return nil }

        let m = totalMonthsInt

        if m < 1 {
            // under 1 month → 24 hours chip
            return "chip24hrs"
        } else if m < 2 {
            // 1.x months → 1 month chip
            return "chip1mon"
        } else if m < 3 {
            // 2.x months → 2 month chip
            return "chip2mon"
        } else if m < 6 {
            // 3–5 months → 3 month chip
            return "chip3mon"
        } else if m < 9 {
            // 6–8 months → 6 month chip
            return "chip6mon"
        } else if m < 12 {
            // 9–11 months → 9 month chip
            return "chip9mon"
        } else {
            // 1 year and beyond → 1 year chip (for now)
            return "chip1yr"
        }
    }

    // Share message for ShareLink
    private var shareMessage: String {
        if !isValidSobriety {
            return "I just started tracking my sobriety with Nightly."
        }

        var parts = ["I've been sober for \(totalDays) day\(totalDays == 1 ? "" : "s")"]

        if totalYearsInt >= 1 {
            parts.append("(\(totalYearsInt) year\(totalYearsInt == 1 ? "" : "s")).")
        } else if totalMonthsInt >= 1 {
            parts.append("(\(totalMonthsInt) month\(totalMonthsInt == 1 ? "" : "s")).")
        }

        if let start = sobrietyStart {
            let df = DateFormatter()
            df.dateStyle = .medium
            parts.append("Sobriety date: \(df.string(from: start)).")
        }

        parts.append("#sober #onedayatatime")

        return parts.joined(separator: " ")
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.black),
                    Color(.systemTeal).opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    topCard

                    if isValidSobriety {
                        timeChipsSection
                    }

                    soberSinceCard

                    shareSection

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .sheet(isPresented: $showingPicker) {
            datePickerSheet
        }
    }

    // MARK: - Top card (days + animated coin)

    private var topCard: some View {
        HStack(spacing: 20) {
            // LEFT: big day counter
            VStack(spacing: 10) {
                Text("Sober for")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(totalDays)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))

                Text("day\(totalDays == 1 ? "" : "s")")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.secondary)

                if !isValidSobriety {
                    Text("Set your sobriety date to begin tracking your time sober.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            // RIGHT: animated coin image, if available
            if let name = chipImageName {
                ZStack {
                    // Glow behind the coin
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 130
                            )
                        )
                        .scaleEffect(1.1 + 0.08 * CGFloat(sin(coinGlowPhase)))
                        .opacity(0.7)

                    // The coin image with spin + pop
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .scaleEffect(coinScale)
                        .rotation3DEffect(
                            .degrees(coinRotation),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .shadow(color: Color.white.opacity(0.8), radius: 18, x: 0, y: 0)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear {
                    startGlowIfNeeded()
                }
                .onChange(of: chipImageName) { _ in
                    playMilestoneAnimation()
                }
            } else {
                // Placeholder circle if no valid sobriety yet
                Circle()
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("Set\nDate")
                            .font(.caption.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.14))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - Animation helpers

    private func startGlowIfNeeded() {
        guard !glowStarted else { return }
        glowStarted = true

        withAnimation(
            Animation.easeInOut(duration: 2.4)
                .repeatForever(autoreverses: true)
        ) {
            coinGlowPhase = .pi * 2
        }
    }

    private func playMilestoneAnimation() {
        // Shrink a bit before popping
        coinScale = 0.7

        withAnimation(
            .spring(response: 0.6, dampingFraction: 0.45, blendDuration: 0.2)
        ) {
            coinScale = 1.2
            coinRotation += 360
        }

        // Relax back to 1.0 scale
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.75, blendDuration: 0.2)
            ) {
                coinScale = 1.0
            }
        }
    }

    // MARK: - Time chips

    private var timeChipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your time sober")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                chipRow(
                    icon: "sparkles",
                    title: "Seconds",
                    value: formattedNumber(totalSeconds),
                    subtitle: "Every second counts"
                )
                chipRow(
                    icon: "clock",
                    title: "Hours",
                    value: formattedNumber(totalHours),
                    subtitle: "One hour at a time"
                )
                chipRow(
                    icon: "sun.max",
                    title: "Days",
                    value: formattedNumber(totalDays),
                    subtitle: "Showing up today"
                )
                chipRow(
                    icon: "calendar",
                    title: "Months (approx.)",
                    value: String(format: "%.1f", totalMonthsApprox),
                    subtitle: "A growing streak"
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Sober since card

    private var soberSinceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sober since")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)

                    Text(sobrietyStartFormatted)
                        .font(.body.weight(.semibold))
                }

                Spacer()

                Button {
                    tempDate = sobrietyStart ?? Date()
                    showingPicker = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: sobrietyStart == nil ? "calendar.badge.plus" : "pencil")
                        Text(sobrietyStart == nil ? "Set date" : "Edit")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(.systemGreen),
                                        Color(.systemTeal)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .foregroundColor(.white)
                }
            }

            Text("Nightly recalculates your sobriety streak automatically as your date changes.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Share section

    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ShareLink(item: shareMessage) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share your progress")
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
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

            Text("Celebrate your milestones with others.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Helpers

    private func chipRow(icon: String, title: String, value: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemPurple),
                                Color(.systemBlue)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(value)
                .font(.headline.monospacedDigit())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.09))
        )
    }

    private func formattedNumber(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    // MARK: - Date picker sheet

    private var datePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker(
                    "Sobriety date",
                    selection: $tempDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()
            }
            .navigationTitle("Set Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingPicker = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        sobrietyStartTS = tempDate.timeIntervalSince1970
                        showingPicker = false
                    }
                    .bold()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SobrietyCounterView()
    }
}
