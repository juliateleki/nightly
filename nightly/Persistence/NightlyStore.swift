//
//  NightlyStore.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

//
//  NightlyStore.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//  Updated: preserves original behavior and adds mood support
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

  // MARK: - Add (backward-compatible)
  /// Original API — still works. Defaults mood to `.neutral`.
  func add(questions: [String], answers: [String]) {
    add(questions: questions, answers: answers, mood: .neutral)
  }

  /// New API — preferred when saving mood from the NewNightlyView.
  func add(questions: [String], answers: [String], mood: Mood) {
    let entry = NightlyEntry(questions: questions, answers: answers, mood: mood)
    add(entry)
  }

  /// Internal helper to insert & persist (newest first).
  func add(_ entry: NightlyEntry) {
    entries.insert(entry, at: 0)
    save()
  }

  // MARK: - Delete
  func delete(at offsets: IndexSet) {
    entries.remove(atOffsets: offsets)
    save()
  }

  // MARK: - Update
  /// Keep your original signature but *preserve mood* from the old entry.
  func updateAnswers(for entryID: UUID, answers: [String]) {
    guard let idx = entries.firstIndex(where: { $0.id == entryID }) else { return }
    let old = entries[idx]
    entries[idx] = NightlyEntry(
      id: old.id,
      date: old.date,
      questions: old.questions,
      answers: answers,
      mood: old.mood // preserve mood
    )
    save()
  }

  /// Optional convenience if you later want to update both answers & mood together.
  func update(for entryID: UUID, questions: [String], answers: [String], mood: Mood) {
    guard let idx = entries.firstIndex(where: { $0.id == entryID }) else { return }
    let old = entries[idx]
    entries[idx] = NightlyEntry(
      id: old.id,
      date: old.date,
      questions: questions,
      answers: answers,
      mood: mood
    )
    save()
  }

  /// Optional: update mood only.
  func updateMood(for entryID: UUID, mood: Mood) {
    guard let idx = entries.firstIndex(where: { $0.id == entryID }) else { return }
    var e = entries[idx]
    e.mood = mood
    entries[idx] = e
    save()
  }

  // MARK: - Persistence
  private func save() {
    do {
      let encoder = JSONEncoder()
      // Keep default strategies to remain compatible with your existing file
      let data = try encoder.encode(entries)
      try data.write(to: fileURL, options: [.atomic])
    } catch {
      print("Failed to save entries: \(error)")
    }
  }

  private func load() {
    do {
      let data = try Data(contentsOf: fileURL)
      let decoder = JSONDecoder()
      // Keep defaults for backward-compatibility with previous encodes
      let decoded = try decoder.decode([NightlyEntry].self, from: data)
      entries = decoded.sorted(by: { $0.date > $1.date })
    } catch {
      entries = []
    }
  }
}
