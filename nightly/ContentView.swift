//
//  ContentView.swift
//  nightly
//
//  Created by Julia Teleki on 8/22/25.
//

import SwiftUI

// MARK: - Model

struct NightlyEntry: Identifiable, Codable, Equatable {
  let id: UUID
  let date: Date
  let questions: [String]
  let answers: [String]

  init(
    id: UUID = UUID(),
    date: Date = Date(),
    questions: [String],
    answers: [String]
  ) {
    self.id = id
    self.date = date
    self.questions = questions
    self.answers = answers
  }
}

// MARK: - Date Formatters

enum DF {
  static let full: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .full
    df.timeStyle = .short
    return df
  }()
  static let long: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .long
    df.timeStyle = .short
    return df
  }()
}

// MARK: - Persistence Store

@MainActor
final class NightlyStore: ObservableObject {
  @Published private(set) var entries: [NightlyEntry] = []

  private let fileURL: URL = {
    let dir = FileManager.default.urls(
      for: .documentDirectory,
      in: .userDomainMask
    ).first!
    return dir.appendingPathComponent("nightly_entries.json")
  }()

  init() { load() }

  func add(questions: [String], answers: [String]) {
    let entry = NightlyEntry(questions: questions, answers: answers)
    entries.insert(entry, at: 0)  // newest first
    save()
  }

  func delete(at offsets: IndexSet) {
    entries.remove(atOffsets: offsets)
    save()
  }

  /// Update only the answers of an existing entry (keeps date/questions snapshot)
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

// MARK: - Root Tabs

struct ContentView: View {
  @StateObject private var store = NightlyStore()

  var body: some View {
    TabView {
      NewNightlyView()
        .environmentObject(store)
        .tabItem { Label("New", systemImage: "square.and.pencil") }

      HistoryView()
        .environmentObject(store)
        .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
    }
  }
}

// MARK: - New Nightly

struct NewNightlyView: View {
  @EnvironmentObject private var store: NightlyStore

  // Edit questions freely; the UI will stay in sync.
  private let questions: [String] = [
    "Were we resentful?",
    "Were we selfish?",
    "Were we dishonest?",
    "Were we afraid?",
    "Do we owe an apology?",
    "Have we kept something to ourselves which should be discussed with another person at once?",
    "Were we kind and loving toward all?",
    "What could we have done better?",
    "Were we thinking of ourselves most of the time?",
    "Or were we thinking of what we could do for others, of what we could pack into the stream of life?",
    "What are we grateful for today?",
    "What are our corrective measures?",
  ]

  // Initialize answers based on questions.count (not a fixed number)
  @State private var answers: [String]
  @State private var showingSaved = false

  init() {
    _answers = State(initialValue: Array(repeating: "", count: questions.count))
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          ForEach(questions.indices, id: \.self) { i in
            QuestionCard(
              question: questions[i],
              answer: bindingForAnswer(i)  // safe binding
            )
          }

          Button(action: saveNightly) {
            HStack(spacing: 8) {
              Image(systemName: "tray.and.arrow.down")
              Text("Save Nightly").fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.tint.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .padding(.top)
        }
        .padding()
      }
      .navigationTitle("Nightly Inventory")
      .toolbar {
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Done") { endEditing() }
        }
      }
      .alert("Saved!", isPresented: $showingSaved) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("Your nightly has been added to History.")
      }
      // If you hot-edit questions and the view stays alive, keep arrays in sync:
      .onAppear { ensureAnswerCapacity() }
    }
  }

  // Defensive binding that grows the array if needed (prevents out-of-range)
  private func bindingForAnswer(_ i: Int) -> Binding<String> {
    Binding(
      get: {
        if i < answers.count { return answers[i] }
        return ""
      },
      set: { newValue in
        if i >= answers.count {
          answers.append(contentsOf: Array(repeating: "", count: i - answers.count + 1))
        }
        answers[i] = newValue
      }
    )
  }

  private func ensureAnswerCapacity() {
    if answers.count != questions.count {
      if answers.count < questions.count {
        answers.append(contentsOf: Array(repeating: "", count: questions.count - answers.count))
      } else {
        answers = Array(answers.prefix(questions.count))
      }
    }
  }

  private func saveNightly() {
    // Save exactly one answer per question (no index errors)
    let trimmed: [String] = (0..<questions.count).map { i in
      (i < answers.count ? answers[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    guard trimmed.contains(where: { !$0.isEmpty }) else { return }
    store.add(questions: questions, answers: trimmed)

    // Reset for the next nightly, matching the current question count
    answers = Array(repeating: "", count: questions.count)
    showingSaved = true
    endEditing()
  }
}

// Small helper to dismiss keyboard (no FocusState needed)
private func endEditing() {
  #if canImport(UIKit)
  UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  #endif
}

// MARK: - Question Card

struct QuestionCard: View {
  let question: String
  @Binding var answer: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(question).font(.headline)

      ZStack(alignment: .topLeading) {
        if answer.isEmpty {
          Text("Type your answer…")
            .foregroundStyle(.secondary)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
        }
        TextEditor(text: $answer)
          .padding(8)
          .frame(minHeight: 110)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(Color(.systemBackground))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(.quaternary, lineWidth: 1)
          )
          .scrollContentBackground(.hidden)
          .textInputAutocapitalization(.sentences)
          .disableAutocorrection(false)
      }
    }
  }
}

// MARK: - History List

struct HistoryView: View {
  @EnvironmentObject private var store: NightlyStore
  @State private var query = ""

  var body: some View {
    NavigationStack {
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
            }.padding()
          }
        } else {
          List {
            ForEach(filteredEntries) { entry in
              NavigationLink {
                NightlyDetailView(entryID: entry.id)   // pass ID, read live from store
              } label: {
                HistoryRow(entry: entry)
              }
            }
            .onDelete(perform: store.delete)
          }
          .listStyle(.insetGrouped)
        }
      }
      .navigationTitle("History")
      .searchable(text: $query, placement: .navigationBarDrawer, prompt: "Search answers")
    }
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

struct HistoryRow: View {
  let entry: NightlyEntry
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(DF.full.string(from: entry.date))
        .font(.headline)
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

// MARK: - Detail (with Share + Edit)

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
            Text(DF.long.string(from: entry.date))
              .font(.title2.weight(.semibold))

            ForEach(entry.questions.indices, id: \.self) { i in
              VStack(alignment: .leading, spacing: 8) {
                Text(entry.questions[i]).font(.headline)
                Text(answerText(entry: entry, index: i))
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(12)
                  .background(
                    RoundedRectangle(cornerRadius: 12)
                      .fill(Color(.secondarySystemBackground))
                  )
              }
            }
          }
          .padding()
        }
        .navigationTitle("Nightly Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItemGroup(placement: .topBarTrailing) {
            ShareLink(item: shareText(for: entry)) {
              Image(systemName: "square.and.arrow.up")
            }
            Button {
              showingEditor = true
            } label: {
              Image(systemName: "pencil")
            }
            .accessibilityLabel("Edit")
          }
        }
        .sheet(isPresented: $showingEditor) {
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

// MARK: - Edit Past Nightly

struct EditNightlyView: View {
  @EnvironmentObject private var store: NightlyStore
  let entryID: UUID

  @Environment(\.dismiss) private var dismiss

  @State private var questions: [String] = []
  @State private var answers: [String] = []

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 20) {
          ForEach(questions.indices, id: \.self) { i in
            QuestionCard(
              question: questions[i],
              answer: bindingForAnswer(i)
            )
          }
          Button {
            saveChanges()
          } label: {
            HStack(spacing: 8) {
              Image(systemName: "tray.and.arrow.down")
              Text("Save Changes").fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.tint.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .padding(.top)
        }
        .padding()
      }
      .navigationTitle("Edit Nightly")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") { dismiss() }
        }
      }
      .onAppear(perform: loadEntryIfNeeded)
    }
  }

  private func loadEntryIfNeeded() {
    guard questions.isEmpty else { return }
    guard let entry = store.entries.first(where: { $0.id == entryID }) else { return }
    questions = entry.questions
    // Ensure answers count matches questions
    let trimmed = entry.answers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    if trimmed.count < questions.count {
      answers = trimmed + Array(repeating: "", count: questions.count - trimmed.count)
    } else {
      answers = Array(trimmed.prefix(questions.count))
    }
  }

  private func bindingForAnswer(_ i: Int) -> Binding<String> {
    Binding(
      get: { i < answers.count ? answers[i] : "" },
      set: { newValue in
        if i >= answers.count {
          answers.append(contentsOf: Array(repeating: "", count: i - answers.count + 1))
        }
        answers[i] = newValue
      }
    )
  }

  private func saveChanges() {
    // Persist exactly one answer per question
    let cleaned = (0..<questions.count).map { i in
      (i < answers.count ? answers[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    store.updateAnswers(for: entryID, answers: cleaned)
    dismiss()
  }
}

// MARK: - Preview

#Preview {
  ContentView()
}
