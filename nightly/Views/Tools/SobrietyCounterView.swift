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

    private var totalYearsInt: Int {
        totalMonthsInt / 12
    }

    // Approximate months for UI chips
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

    // Share message
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
                    Color(.systemTeal).opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    daysAndCoinCard

                    if isValidSobriety {
                        timeChipsSection
                    }

                    soberSinceCard

                    shareSection

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

    private var daysAndCoinCard: some View {
        HStack(spacing: 20) {

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
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)

            if isValidSobriety {
                SobrietyChipView(months: totalMonthsInt)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Circle()
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 2)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("Set\ndate")
                            .font(.caption.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
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
    }

    private var timeChipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your time sober")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                chipRow(icon: "sparkles", title: "Seconds", value: formattedNumber(totalSeconds), subtitle: "Every second counts")
                chipRow(icon: "clock", title: "Hours", value: formattedNumber(totalHours), subtitle: "One hour at a time")
                chipRow(icon: "sun.max", title: "Days", value: formattedNumber(totalDays), subtitle: "Showing up today")
                chipRow(icon: "calendar", title: "Months (approx.)", value: String(format: "%.1f", totalMonthsApprox), subtitle: "A growing streak")
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

            Text("Nightly tracks your savings and recalculates your sobriety streak automatically.")
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

    // MARK: - Row builder

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

    // MARK: - Date Picker

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
                    Button("Cancel") { showingPicker = false }
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

    private func formattedNumber(_ value: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let top = CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.15)
        let left = CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY - rect.height * 0.18)
        let right = CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.maxY - rect.height * 0.18)

        path.move(to: top)
        path.addLine(to: left)
        path.addLine(to: right)
        path.addLine(to: top)
        return path
    }
}

// MARK: - Curved text helper

private struct ArcText: View {
    let text: String
    let radius: CGFloat
    let startAngle: Angle
    let endAngle: Angle

    var body: some View {
        GeometryReader { geo in
            let chars = Array(text)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let start = startAngle.radians
            let end = endAngle.radians
            let count = max(chars.count - 1, 1)
            let step = (end - start) / Double(count)

            ZStack {
                ForEach(Array(chars.enumerated()), id: \.offset) { index, char in
                    let angle = start + Double(index) * step
                    let x = center.x + radius * cos(angle)
                    let y = center.y + radius * sin(angle)

                    Text(String(char))
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.white)
                        .position(x: x, y: y)
                        .rotationEffect(Angle(radians: angle + .pi / 2))
                }
            }
        }
    }
}

// MARK: - Sobriety coin view

private struct SobrietyChipView: View {
    let months: Int

    private var centerNumberText: String {
        if months < 1 {
            return "24"
        } else if months < 12 {
            return "\(months)"
        } else {
            let years = max(1, months / 12)
            return "\(min(years, 50))"
        }
    }

    private var bottomLabelText: String {
        if months < 1 {
            return "HOURS"
        } else if months < 12 {
            return "MONTHS"
        } else {
            return "YEARS"
        }
    }

    private func gradientColors() -> [Color] {
        if months < 1 { return [Color(.systemGray3), Color(.systemGray5)] }
        switch months {
        case 1: return [Color(red: 0.95, green: 0.25, blue: 0.25), Color(red: 0.70, green: 0.05, blue: 0.05)]
        case 2: return [Color(red: 0.98, green: 0.85, blue: 0.35), Color(red: 0.90, green: 0.70, blue: 0.10)]
        case 3: return [Color(red: 0.10, green: 0.55, blue: 0.30), Color(red: 0.03, green: 0.30, blue: 0.18)]
        case 4: return [Color(red: 0.98, green: 0.88, blue: 0.40), Color(red: 0.86, green: 0.75, blue: 0.20)]
        case 5: return [Color(red: 0.90, green: 0.15, blue: 0.25), Color(red: 0.60, green: 0.05, blue: 0.10)]
        case 6: return [Color(red: 0.15, green: 0.35, blue: 0.90), Color(red: 0.05, green: 0.10, blue: 0.50)]
        case 7: return [Color.purple, Color(red: 0.35, green: 0.00, blue: 0.60)]
        case 8: return [Color.orange, Color(red: 0.90, green: 0.40, blue: 0.05)]
        case 9: return [Color(red: 0.85, green: 0.30, blue: 0.85), Color(red: 0.55, green: 0.10, blue: 0.60)]
        case 10: return [Color(red: 0.05, green: 0.55, blue: 0.35), Color(red: 0.02, green: 0.30, blue: 0.20)]
        case 11: return [Color(red: 0.85, green: 0.10, blue: 0.10), Color(red: 0.55, green: 0.05, blue: 0.05)]
        default: return [Color(.systemTeal), Color(.systemBlue)]
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
                .stroke(Color.white.opacity(0.55), lineWidth: 2.5)

            Triangle()
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .padding(22)

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 52, height: 52)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                )
                .overlay(
                    Text(centerNumberText)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                )

            ArcText(
                text: "TO THINE OWN SELF BE TRUE",
                radius: 62,
                startAngle: .degrees(-160),
                endAngle: .degrees(-20)
            )

            VStack {
                Text("UNITY")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.top, 35)

            VStack {
                Spacer()
                Text(bottomLabelText)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 14)
            }

            HStack {
                VStack {
                    Spacer()
                    Text("RECOVERY")
                        .font(.caption2.weight(.semibold))
                        .rotationEffect(.degrees(-38))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack {
                    Spacer()
                    Text("SERVICE")
                        .font(.caption2.weight(.semibold))
                        .rotationEffect(.degrees(38))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 36)
            .padding(.horizontal, 18)
        }
        .frame(width: 140, height: 140)
    }
}

#Preview {
    NavigationStack {
        SobrietyCounterView()
            .environmentObject(NightlyStore())
    }
}
