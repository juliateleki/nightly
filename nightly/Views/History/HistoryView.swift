//
//  HistoryView.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

struct HistoryView: View {
  @EnvironmentObject private var store: NightlyStore
  @State private var query = ""

  var body: some View {
    Group {
      if filteredEntries.isEmpty {
        if #available(iOS 17, *) {
          ContentUnavailableView(
            "No Nightlies Yet",
            systemImage: "tray",
            description: Text("Nightlies you save will appear here. Create one from the New tab.")
          )
        } else {
          VStack(spacing: 8) {
            Image(systemName: "tray")
            Text("No Nightlies Yet").font(.headline)
            Text("Nightlies you save will appear here. Create one from the New tab.")
              .foregroundStyle(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
          }
          .padding()
        }
      } else {
        VStack(spacing: 8) {
          // Chronological for trend (oldest -> newest)
          MoodSparkline(moods: store.entries.reversed().map { $0.mood })
            .padding(.horizontal)

          List {
            ForEach(filteredEntries) { entry in
              NavigationLink {
                NightlyDetailView(entryID: entry.id)
              } label: {
                HistoryRow(entry: entry)
              }
            }
            .onDelete(perform: store.delete)
          }
          .listStyle(.insetGrouped)
        }
      }
    }
    .searchable(text: $query, placement: .navigationBarDrawer, prompt: "Search answers")
  }

  private var filteredEntries: [NightlyEntry] {
    let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !q.isEmpty else { return store.entries }
    return store.entries.filter { entry in
      DF.full.string(from: entry.date).lowercased().contains(q)
      || entry.answers.contains { $0.lowercased().contains(q) }
    }
  }
}
