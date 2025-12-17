//
//  nightlyTests.swift
//  nightlyTests
//
//  Created by Julia Teleki on 8/22/25.
//

import Foundation
import Testing
@testable import nightly

struct nightlyTests {

    @Test
    func dailyQuotes_containsAtLeastOneQuote() async throws {
        #expect(!DailyQuotes.all.isEmpty)
    }

    @Test
    func dailyQuote_isDeterministicForSameDate() async throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = Date(timeIntervalSince1970: 1_700_000_000)

        let quote1 = DailyQuotes.quote(for: date, calendar: calendar)
        let quote2 = DailyQuotes.quote(for: date, calendar: calendar)

        #expect(quote1 == quote2)
    }

    @Test
    func dailyQuote_changesOnDifferentDays() async throws {
        let calendar = Calendar(identifier: .gregorian)

        let day1 = Date(timeIntervalSince1970: 1_700_000_000)
        let day2 = calendar.date(byAdding: .day, value: 1, to: day1)!

        let quote1 = DailyQuotes.quote(for: day1, calendar: calendar)
        let quote2 = DailyQuotes.quote(for: day2, calendar: calendar)

        #expect(quote1 != quote2 || DailyQuotes.all.count == 1)
    }

    @Test
    func nightlyEntry_encodesAndDecodesCorrectly() async throws {
        let entry = NightlyEntry(
            id: UUID(),
            date: Date(timeIntervalSince1970: 1_700_000_000),
            questions: ["How was today?", "What are you grateful for?"],
            answers: ["Pretty calm.", "Coffee and sunlight."],
            mood: .good
        )

        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(NightlyEntry.self, from: data)

        #expect(decoded.id == entry.id)
        #expect(decoded.date == entry.date)
        #expect(decoded.questions == entry.questions)
        #expect(decoded.answers == entry.answers)
        #expect(decoded.mood == entry.mood)
    }


    @Test
    func mood_hasEmojiAndLabelForAllCases() async throws {
        for mood in Mood.allCases {
            #expect(!mood.emoji.isEmpty)
            #expect(!mood.label.isEmpty)
        }
        #expect(Mood.allCases.count == 5)
    }


    @Test
    func nightlyStore_addsEntryAndSortsNewestFirst() async throws {
        await MainActor.run {
            let store = NightlyStore()

            let older = NightlyEntry(
                date: Date().addingTimeInterval(-3600),
                questions: ["Q1"],
                answers: ["A1"],
                mood: .neutral
            )

            let newer = NightlyEntry(
                date: Date(),
                questions: ["Q2"],
                answers: ["A2"],
                mood: .good
            )

            store.add(older)
            store.add(newer)

            #expect(store.entries.count >= 2)
            #expect(store.entries.first == newer)
        }
    }

  @Test
  func nightlyStore_deleteRemovesEntry() async throws {
      await MainActor.run {
          let store = NightlyStore()

          let entry = NightlyEntry(
              date: Date(),
              questions: ["How was today?", "What are you grateful for?"],
              answers: ["Okay.", "My bed."],
              mood: .neutral
          )

          store.add(entry)

          guard let idx = store.entries.firstIndex(of: entry) else {
              #expect(Bool(false), "Entry should exist after add")
              return
          }


          let countAfterAdd = store.entries.count
            store.delete(at: IndexSet(integer: idx))

            #expect(store.entries.count == countAfterAdd - 1)
            #expect(!store.entries.contains(entry))
          }
      }

}
