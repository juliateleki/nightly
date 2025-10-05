//
//  MoodPicker.swift
//  nightly
//
//  Created by Julia Teleki on 10/5/25.
//

import SwiftUI

public struct MoodPicker: View {
  @Binding var mood: Mood

  public init(mood: Binding<Mood>) { self._mood = mood }

  public var body: some View {
    VStack(spacing: 8) {
      Text("Tonight I feel…")
        .font(.headline)
      HStack(spacing: 12) {
        ForEach(Mood.allCases) { m in
          Button {
            mood = m
          } label: {
            VStack(spacing: 4) {
              Text(m.emoji).font(.system(size: 28))
              Text(m.label).font(.caption)
            }
            .padding(8)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(m == mood ? Color.primary.opacity(0.6) : Color.secondary.opacity(0.25),
                        lineWidth: m == mood ? 2 : 1)
            )
          }
          .buttonStyle(.plain)
          .accessibilityLabel(Text(m.label))
          .accessibilityAddTraits(m == mood ? .isSelected : [])
        }
      }
    }
    .padding(.vertical, 6)
  }
}
