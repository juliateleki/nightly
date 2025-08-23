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
        "Or were we thinking of what we could do for others, of what we could pack into the stream of life?"
    ]
    
    @State private var answers: [String] = Array(repeating: "", count: 10)
    @State private var showingSaved = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(questions.indices, id: \.self) { i in
                        QuestionCard(question: questions[i], answer: $answers[i])
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
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your nightly has been added to History.")
            }
        }
    }
    
    private func saveNightly() {
        let cleaned = answers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard cleaned.contains(where: { !$0.isEmpty }) else { return }
        store.add(questions: questions, answers: cleaned)
        answers = Array(repeating: "", count: questions.count)
        showingSaved = true
        endEditing()
    }
}

// Small helper to dismiss keyboard without FocusState bloat
private func endEditing() {
#if canImport(UIKit)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
}

// MARK: - Question Card (extracted to keep type-check simple)

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
                                NightlyDetailView(entry: entry)
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
            DF.full.string(from: entry.date).lowercased().contains(q) ||
            entry.answers.contains { $0.lowercased().contains(q) }
        }
    }
}

// Row extracted to avoid large inline view builders
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
        entry.answers.first(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) ?? "No answers recorded."
    }
}

// MARK: - Detail

struct NightlyDetailView: View {
    let entry: NightlyEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(DF.long.string(from: entry.date))
                    .font(.title2.weight(.semibold))
                
                ForEach(entry.questions.indices, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.questions[i]).font(.headline)
                        Text(answer(at: i))
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
    }
    
    private func answer(at i: Int) -> String {
        guard i < entry.answers.count else { return "—" }
        let t = entry.answers[i].trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "—" : t
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
