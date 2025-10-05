//
//  NightlyDetailView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

//
//  NightlyDetailView.swift
//  nightly
//

import SwiftUI

struct NightlyDetailView: View {
  @EnvironmentObject private var store: NightlyStore
  let entryID: UUID

  @State private var showingEditor = false

  private var entryIndex: Int? { store.entries.firstIndex(where: { $0.id == entryID }) }
  private var entry: NightlyEntry? { entryIndex.map { store.entries[$0] } }

  var body: some View {
    Group {
      if let entry {
        ScrollView {
          VStack(alignment: .leading, spacing: 16) {

            // Header with mood + date
            HStack(alignment: .firstTextBaseline, spacing: 10) {
              Text(entry.mood.emoji)
                .font(.largeTitle)
                .accessibilityLabel(entry.mood.label)
              VStack(alignment: .leading, spacing: 2) {
                Text(DF.long.string(from: entry.date))
                  .font(.title2.weight(.semibold))
                Text(entry.mood.label)
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }
              Spacer()
            }

            ForEach(entry.questions.indices, id: \.self) { i in
              VStack(alignment: .leading, spacing: 8) {
                Text(entry.questions[i]).font(.headline)
                Text(answerText(entry: entry, index: i))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(12)
                  .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
              }
            }
          }
          .padding()
        }
        .navigationTitle("Nightly Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItemGroup(placement: .topBarTrailing) {
            ShareLink(item: shareText(for: entry)) { Image(systemName: "square.and.arrow.up") }
            Button { showingEditor = true } label: { Image(systemName: "pencil") }
              .accessibilityLabel("Edit")
          }
        }
        .sheet(isPresented: $showingEditor) {
          // Uses your existing editor by ID
          EditNightlyView(entryID: entry.id)
            .environmentObject(store)
        }
      } else {
        if #available(iOS 17, *) {
          ContentUnavailableView("Entry not found", systemImage: "exclamationmark.triangle")
        } else {
          Text("Entry not found").foregroundStyle(.secondary)
        }
      }
    }
  }

  private func answerText(entry: NightlyEntry, index: Int) -> String {
    guard index < entry.answers.count else { return "—" }
    let t = entry.answers[index].trimmingCharacters(in: .whitespacesAndNewlines)
    return t.isEmpty ? "—" : t
  }

  private func shareText(for entry: NightlyEntry) -> String {
    var lines: [String] = []
    lines.append("Nightly Inventory — \(DF.long.string(from: entry.date))")
    lines.append("Mood: \(entry.mood.emoji) \(entry.mood.label)")
    lines.append("")
    for (q, a) in zip(entry.questions, entry.answers) {
      let ans = a.trimmingCharacters(in: .whitespacesAndNewlines)
      lines.append("• \(q)")
      lines.append(ans.isEmpty ? "  —" : "  \(ans)")
      lines.append("")
    }
    return lines.joined(separator: "\n")
  }
}
