//
//  NightlyStore.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import Foundation
import SwiftUI

@MainActor
final class NightlyStore: ObservableObject {
  @Published private(set) var entries: [NightlyEntry] = []

  private let fileURL: URL = {
    let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    return dir.appendingPathComponent("nightly_entries.json")
  }()

  init() { load() }

  func add(questions: [String], answers: [String]) {
    let entry = NightlyEntry(questions: questions, answers: answers)
    entries.insert(entry, at: 0) // newest first
    save()
  }

  func delete(at offsets: IndexSet) {
    entries.remove(atOffsets: offsets)
    save()
  }

  func updateAnswers(for entryID: UUID, answers: [String]) {
    guard let idx = entries.firstIndex(where: { $0.id == entryID }) else { return }
    let old = entries[idx]
    entries[idx] = NightlyEntry(id: old.id, date: old.date, questions: old.questions, answers: answers)
    save()
  }

  private func save() {
    do {
      let data = try JSONEncoder().encode(entries)
      try data.write(to: fileURL, options: [.atomic])
    } catch {
      print("Failed to save entries: \(error)")
    }
  }

  private func load() {
    do {
      let data = try Data(contentsOf: fileURL)
      let decoded = try JSONDecoder().decode([NightlyEntry].self, from: data)
      entries = decoded.sorted(by: { $0.date > $1.date })
    } catch {
      entries = []
    }
  }
}
