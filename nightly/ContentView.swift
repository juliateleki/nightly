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

  init(id: UUID = UUID(), date: Date = Date(), questions: [String], answers: [String]) {
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

  /// Update only answers of an existing entry (keeps original date & question snapshot)
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

// MARK: - Menu

enum MenuItem: String, CaseIterable, Identifiable {
  case new = "New Nightly"
  case history = "Past Nightlies"
  case sobriety = "Sobriety Counter"

  var id: String { rawValue }
  var systemImage: String {
    switch self {
      case .new: return "square.and.pencil"
      case .history: return "clock.arrow.circlepath"
      case .sobriety: return "heart.text.square"
    }
  }
}

// MARK: - Root Shell (menu overlays nav/title)

struct ContentView: View {
  @StateObject private var store = NightlyStore()
  @State private var selection: MenuItem = .new
  @State private var isMenuOpen: Bool = false

  var body: some View {
    ZStack { // Menu + dimmer sit ABOVE NavigationStack
      NavigationStack {
        Group {
          switch selection {
            case .new:
              NewNightlyView()
                .navigationTitle("Nightly Inventory")
            case .history:
              HistoryView()
                .navigationTitle("History")
            case .sobriety:
              SobrietyCounterView()
                .navigationTitle("Sobriety Counter")
          }
        }
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) { // top-right hamburger
            Button {
              withAnimation(.easeInOut(duration: 0.2)) { isMenuOpen.toggle() }
            } label: {
              Image(systemName: "line.3.horizontal")
            }
            .accessibilityLabel("Menu")
          }
        }
      }

      // Dim overlay
      if isMenuOpen {
        Color.black.opacity(0.25)
          .ignoresSafeArea()
          .zIndex(1)
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) { isMenuOpen = false }
          }
      }

      // Solid side menu (slides from right, covers nav/title)
      SideMenuRight(isOpen: $isMenuOpen, selection: $selection)
        .zIndex(2)
    }
    .environmentObject(store) // inject store ONCE for all children, pushes, and sheets
  }
}

struct SideMenuRight: View {
  @Binding var isOpen: Bool
  @Binding var selection: MenuItem

  private let width: CGFloat = 300

  // Top safe-area inset (works on all iPhones with notch/Dynamic Island)
  private var safeTopInset: CGFloat {
    #if canImport(UIKit)
    return UIApplication.shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })?
      .safeAreaInsets.top ?? 0
    #else
    return 0
    #endif
  }

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 10) {
        HStack(spacing: 10) {
          Image(systemName: "moon.stars.fill")
          Text("nightly")
            .font(.title3.weight(.semibold))
        }
        .padding(.bottom, 12)

        ForEach(MenuItem.allCases) { item in
          Button {
            withAnimation(.easeInOut(duration: 0.2)) {
              selection = item
              isOpen = false
            }
          } label: {
            HStack(spacing: 12) {
              Image(systemName: item.systemImage)
              Text(item.rawValue)
              Spacer()
              if item == selection {
                Image(systemName: "checkmark").foregroundStyle(.secondary)
              }
            }
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(item == selection ? Color.accentColor.opacity(0.12) : .clear)
            )
          }
          .buttonStyle(.plain)
        }

        Spacer()
      }
      .padding(.top, safeTopInset + 8)          // <- push below the speaker/notch
      .padding(.horizontal, 16)
      .frame(width: width, alignment: .topLeading)
      .frame(maxHeight: .infinity)
      .background(Color(.systemBackground))     // solid
      .shadow(radius: 10)
      .offset(x: isOpen ? 0 : width)            // slide in from right
      .animation(.easeInOut(duration: 0.2), value: isOpen)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
    .ignoresSafeArea(edges: .bottom)            // <- don't ignore top; only bottom
  }
}


// MARK: - New Nightly

struct NewNightlyView: View {
  @EnvironmentObject private var store: NightlyStore

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
    "What are our corrective measures?"
  ]

  @State private var answers: [String]
  @State private var showingSaved = false

  init() {
    _answers = State(initialValue: Array(repeating: "", count: 12))
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        ForEach(questions.indices, id: \.self) { i in
          QuestionCard(question: questions[i], answer: bindingForAnswer(i))
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
    .alert("Saved!", isPresented: $showingSaved) {
      Button("OK", role: .cancel) { }
    } message: {
      Text("Your nightly has been added to History.")
    }
    .onAppear { ensureAnswerCapacity() }
  }

  // Defensive binding to prevent index-out-of-range if you add questions
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

  private func ensureAnswerCapacity() {
    if answers.count < questions.count {
      answers.append(contentsOf: Array(repeating: "", count: questions.count - answers.count))
    } else if answers.count > questions.count {
      answers = Array(answers.prefix(questions.count))
    }
  }

  private func saveNightly() {
    let trimmed: [String] = (0..<questions.count).map { i in
      (i < answers.count ? answers[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    guard trimmed.contains(where: { !$0.isEmpty }) else { return }
    store.add(questions: questions, answers: trimmed)
    answers = Array(repeating: "", count: questions.count)
    showingSaved = true
    endEditing()
  }
}

// Dismiss keyboard helper
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
          .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
          .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary, lineWidth: 1))
          .scrollContentBackground(.hidden)
          .textInputAutocapitalization(.sentences)
          .disableAutocorrection(false)
      }
    }
  }
}

// MARK: - History

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
          }.padding()
        }
      } else {
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

struct HistoryRow: View {
  let entry: NightlyEntry
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(DF.full.string(from: entry.date)).font(.headline)
      Text(previewText(for: entry)).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
    }
    .padding(.vertical, 4)
  }

  private func previewText(for entry: NightlyEntry) -> String {
    entry.answers.first { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } ?? "No answers recorded."
  }
}

// MARK: - Detail (Share + Edit)

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
            Text(DF.long.string(from: entry.date)).font(.title2.weight(.semibold))

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
            Button { showingEditor = true } label: { Image(systemName: "pencil") }.accessibilityLabel("Edit")
          }
        }
        .sheet(isPresented: $showingEditor) {
          EditNightlyView(entryID: entry.id) // inherits environmentObject from root
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
            QuestionCard(question: questions[i], answer: bindingForAnswer(i))
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
    let trimmed = entry.answers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    answers = trimmed.count < questions.count
      ? trimmed + Array(repeating: "", count: questions.count - trimmed.count)
      : Array(trimmed.prefix(questions.count))
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
    let cleaned = (0..<questions.count).map { i in
      (i < answers.count ? answers[i] : "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    store.updateAnswers(for: entryID, answers: cleaned)
    dismiss()
  }
}

// MARK: - Sobriety Counter

struct SobrietyCounterView: View {
  // Store as epoch seconds so @AppStorage is robust across locales/timezones
  @AppStorage("sobrietyStart_ts") private var sobrietyStartTS: Double = 0
  @State private var showingPicker = false
  @State private var tempDate: Date = Date()

  private var sobrietyStart: Date? {
    sobrietyStartTS > 0 ? Date(timeIntervalSince1970: sobrietyStartTS) : nil
  }

  private var daysSober: Int? {
    guard let start = sobrietyStart else { return nil }
    let cal = Calendar.current
    let startDay = cal.startOfDay(for: start)
    let today = cal.startOfDay(for: Date())
    return cal.dateComponents([.day], from: startDay, to: today).day
  }

  var body: some View {
    VStack(spacing: 20) {
      if let days = daysSober {
        Text("\(days) days sober")
          .font(.system(size: 40, weight: .bold, design: .rounded))
        if let start = sobrietyStart {
          Text("Since \(DF.long.string(from: start))").foregroundStyle(.secondary)
        }
      } else {
        Text("No sobriety date set")
          .font(.title3.weight(.semibold))
          .foregroundStyle(.secondary)
      }

      HStack(spacing: 12) {
        Button {
          tempDate = sobrietyStart ?? Date()
          showingPicker = true
        } label: {
          Label(sobrietyStart == nil ? "Set Sobriety Date" : "Change Date", systemImage: "calendar")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.tint.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        if sobrietyStart != nil {
          Button(role: .destructive) {
            sobrietyStartTS = 0
          } label: {
            Label("Clear", systemImage: "xmark.circle")
              .frame(maxWidth: .infinity)
              .padding(.vertical, 12)
              .background(Color.red.opacity(0.12))
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
        }
      }

      Spacer()
    }
    .padding()
    .sheet(isPresented: $showingPicker) {
      NavigationStack {
        VStack(alignment: .leading, spacing: 16) {
          DatePicker("Sobriety start date", selection: $tempDate, displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .padding(.top)
          Spacer()
        }
        .padding()
        .navigationTitle("Set Date")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) { Button("Cancel") { showingPicker = false } }
          ToolbarItem(placement: .topBarTrailing) {
            Button("Save") {
              sobrietyStartTS = tempDate.timeIntervalSince1970
              showingPicker = false
            }.bold()
          }
        }
      }
    }
  }
}

// MARK: - Preview

#Preview {
  ContentView()
}
