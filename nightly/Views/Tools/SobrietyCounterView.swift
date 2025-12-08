//
//  SobrietyCounterView.swift
//  nightly
//
//  Restyled with colorful chips and sobriety coin
//

import SwiftUI

struct SobrietyCounterView: View {
    @AppStorage("sobrietyStart_ts") private var sobrietyStartTS: Double = 0
    @State private var showingPicker = false
    @State private var tempDate: Date = Date()

    @Environment(\.colorScheme) private var colorScheme

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

    // Calendar-based full months between start and now
    private var totalMonthsInt: Int {
        guard let start = sobrietyStart, isValidSobriety else { return 0 }
        let comps = Calendar.current.dateComponents([.month], from: start, to: now)
        return max(0, comps.month ?? 0)
    }

    // Approximate months (for the text chip)
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

    // MARK: - Body

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.black),
                    Color(.systemTeal).opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // Main counter + sobriety chip
                    daysCounterCard

                    if isValidSobriety {
                        timeChipsSection
                    }

                    soberSinceCard

                    Spacer(minLength: 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .sheet(isPresented: $showingPicker) {
            datePickerSheet
        }
    }

    // MARK: - Sections

    private var daysCounterCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 10) {
                Text("Sober for")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(totalDays)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))

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
            .frame(maxWidth: .infinity, alignment: .leading)

            // Sobriety chip on the right
            if isValidSobriety {
                SobrietyChipView(
                    label: chipLabel,
                    months: totalMonthsInt
                )
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
        .foregroundColor(.primary)
    }

    // Label displayed on the chip
    private var chipLabel: String {
        // Under 1 month → “24h”
        if totalMonthsInt < 1 {
            return "24h"
        } else {
            return "\(min(totalMonthsInt, 99))"
        }
    }

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
                    if let start = sobrietyStart {
                        tempDate = start
                    } else {
                        tempDate = Date()
                    }
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

            Text("You can update this if your sobriety date changes. Nightly will recalculate your total time sober automatically.")
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

    // MARK: - Chip row

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

    // MARK: - Date Picker Sheet

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
            .navigationTitle("Set Sobriety Date")
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

    // MARK: - Helpers

    private func formattedNumber(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Sobriety chip view

private struct SobrietyChipView: View {
    let label: String      // "24h" or month number as String
    let months: Int        // full calendar months sober

    private func gradientColors() -> [Color] {
        // Inspired by AA chip colors; tweaked to fit dark theme
        if months < 1 {
            // 24 hours – silver/gray
            return [Color(.systemGray3), Color(.systemGray5)]
        }
        switch months {
        case 1:
            return [Color(red: 0.95, green: 0.25, blue: 0.25), Color(red: 0.70, green: 0.05, blue: 0.05)] // red
        case 2:
            return [Color(red: 0.98, green: 0.85, blue: 0.35), Color(red: 0.90, green: 0.70, blue: 0.10)] // gold
        case 3:
            return [Color(red: 0.10, green: 0.55, blue: 0.30), Color(red: 0.03, green: 0.30, blue: 0.18)] // green
        case 4:
            return [Color(red: 0.98, green: 0.88, blue: 0.40), Color(red: 0.86, green: 0.75, blue: 0.20)] // yellow-gold
        case 5:
            return [Color(red: 0.90, green: 0.15, blue: 0.25), Color(red: 0.60, green: 0.05, blue: 0.10)] // crimson
        case 6:
            return [Color(red: 0.15, green: 0.35, blue: 0.90), Color(red: 0.05, green: 0.10, blue: 0.50)] // blue
        case 7:
            return [Color.purple, Color(red: 0.35, green: 0.00, blue: 0.60)]
        case 8:
            return [Color.orange, Color(red: 0.90, green: 0.40, blue: 0.05)]
        case 9:
            return [Color(red: 0.85, green: 0.30, blue: 0.85), Color(red: 0.55, green: 0.10, blue: 0.60)]
        case 10:
            return [Color(red: 0.05, green: 0.55, blue: 0.35), Color(red: 0.02, green: 0.30, blue: 0.20)]
        case 11:
            return [Color(red: 0.85, green: 0.10, blue: 0.10), Color(red: 0.55, green: 0.05, blue: 0.05)]
        default:
            // 12+ months – teal/blue “year+” chip
            return [Color(.systemTeal), Color(.systemBlue)]
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors(),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 4)

            Circle()
                .stroke(Color.white.opacity(0.35), lineWidth: 2)

            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text(months < 1 ? "hours" : "months")
                    .font(.caption2.weight(.semibold))
                    .textCase(.uppercase)
            }
            .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
    }
}

#Preview {
    NavigationStack {
        SobrietyCounterView()
    }
}
