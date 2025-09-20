//
//  HistoryRow.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct HistoryRow: View {
  let entry: NightlyEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(DF.full.string(from: entry.date)).font(.headline)
      Text(previewText(for: entry))
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(2)
    }
    .padding(.vertical, 4)
  }

  private func previewText(for entry: NightlyEntry) -> String {
    entry.answers.first {
      !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    } ?? "No answers recorded."
  }
}

//#Preview {
//  let entry = NightlyEntry(
//    date: Date(),
//    answers: ["Hello", "World"],
//    questions: <#[String]#>
//  )
//  HistoryRow(entry: entry)
//}
