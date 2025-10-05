//
//  MoodSparkline.swift
//  nightly
//
//  Created by Julia Teleki on 10/5/25.
//

import SwiftUI

public struct MoodSparkline: View {
  public let moods: [Mood]
  public var showMarkers: Bool = true
  public var lineWidth: CGFloat = 2.0
  public var chartHeight: CGFloat = 120
  public var labelWidth: CGFloat = 80
  public var rightPadding: CGFloat = 20
  public var yLabels: [String] = ["Excellent", "Good", "Neutral", "Low", "Very Low"]

  public init(
    moods: [Mood],
    showMarkers: Bool = true,
    lineWidth: CGFloat = 2.0,
    chartHeight: CGFloat = 120,
    labelWidth: CGFloat = 80,
    rightPadding: CGFloat = 20,
    yLabels: [String] = ["Excellent", "Good", "Neutral", "Low", "Very Low"]
  ) {
    self.moods = moods
    self.showMarkers = showMarkers
    self.lineWidth = lineWidth
    self.chartHeight = chartHeight
    self.labelWidth = labelWidth
    self.rightPadding = rightPadding
    self.yLabels = yLabels
  }

  public var body: some View {
    VStack(alignment: .center, spacing: 0) {
      // Top padding before title
      Spacer(minLength: 8)

      // Title — now gray to match y-axis labels
      Text("Mood Tracker")
        .font(.headline)
        .foregroundStyle(.secondary)
        .padding(.bottom, 25) // space between title and chart

      HStack(alignment: .center, spacing: 8) {
        // Y-axis labels
        VStack(spacing: 0) {
          ForEach(0..<yLabels.count, id: \.self) { i in
            Text(yLabels[i])
              .font(.caption2)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, alignment: .leading)
            if i < yLabels.count - 1 { Spacer(minLength: 0) }
          }
        }
        .frame(width: labelWidth, height: chartHeight)

        // Chart
        GeometryReader { geo in
          let fullWidth = geo.size.width
          let width = fullWidth - rightPadding
          let size = CGSize(width: width, height: geo.size.height)

          let values = moods.map { Double($0.rawValue) }
          let minV = 1.0, maxV = 5.0
          let count = max(values.count, 2)
          let stepX = size.width / CGFloat(count - 1)

          let linePath: Path = {
            var p = Path()
            if values.isEmpty {
              let y = yPos(for: 3.0, in: size, minV: minV, maxV: maxV)
              p.move(to: .init(x: 0, y: y))
              p.addLine(to: .init(x: size.width, y: y))
            } else {
              for (i, v) in values.enumerated() {
                let x = CGFloat(i) * stepX
                let y = yPos(for: v, in: size, minV: minV, maxV: maxV)
                if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                else { p.addLine(to: CGPoint(x: x, y: y)) }
              }
            }
            return p
          }()

          let fillPath: Path = {
            var p = linePath
            p.addLine(to: CGPoint(x: size.width, y: size.height))
            p.addLine(to: CGPoint(x: 0, y: size.height))
            p.closeSubpath()
            return p
          }()

          ZStack {
            // Grid lines aligned with labels
            ForEach(0..<5, id: \.self) { i in
              Path { p in
                let y = size.height * CGFloat(Double(i) / 4.0)
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
              }
              .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            }

            // Fill
            fillPath
              .fill(
                LinearGradient(
                  colors: [Color.accentColor.opacity(0.18), Color.clear],
                  startPoint: .top,
                  endPoint: .bottom
                )
              )

            // Line
            linePath
              .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
              .foregroundStyle(Color.accentColor)

            // Endpoint marker
            if showMarkers, let last = values.last {
              let x = CGFloat(values.count - 1) * stepX
              let y = yPos(for: last, in: size, minV: minV, maxV: maxV)
              Circle()
                .fill(Color.accentColor)
                .frame(width: 8, height: 8)
                .position(x: x, y: y)
            }
          }
        }
        .frame(height: chartHeight)
      }
      .frame(height: chartHeight)

      Spacer(minLength: 8) // padding after chart
    }
    .frame(height: chartHeight + 56)
  }

  private func yPos(for value: Double, in size: CGSize, minV: Double, maxV: Double) -> CGFloat {
    let t = (value - minV) / (maxV - minV)
    return size.height - CGFloat(t) * size.height
  }
}
