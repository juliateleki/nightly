//
//  DailyQuotes.swift
//  nightly
//
//  Created by Julia Teleki on 9/20/25.
//

import Foundation

struct DailyQuote: Equatable, Codable {
  let text: String
  let author: String?
}

enum DailyQuotes {
  // 31 short, original lines (edit/extend freely)
  static let all: [DailyQuote] = [
    .init(text: "Small steps compound into big change.", author: "Nightly"),
    .init(text: "Consistency beats intensity when intensity quits.", author: "Nightly"),
    .init(text: "Done imperfectly is better than perfectly imagined.", author: "Nightly"),
    .init(text: "Your future thanks you for what you practice today.", author: "Nightly"),
    .init(text: "Discomfort is often the doorway to growth.", author: "Nightly"),
    .init(text: "Clarity comes from action, not overthinking.", author: "Nightly"),
    .init(text: "Direction matters more than speed.", author: "Nightly"),
    .init(text: "Tiny wins keep the flame alive.", author: "Nightly"),
    .init(text: "What you repeat, you become.", author: "Nightly"),
    .init(text: "Progress loves patience.", author: "Nightly"),
    .init(text: "You don’t need more time—just the next right step.", author: "Nightly"),
    .init(text: "Energy follows attention. Guard it well.", author: "Nightly"),
    .init(text: "You are allowed to be a work in progress.", author: "Nightly"),
    .init(text: "Courage is quiet, persistent effort.", author: "Nightly"),
    .init(text: "Start where you are. Use what you have.", author: "Nightly"),
    .init(text: "Your habits vote for your identity.", author: "Nightly"),
    .init(text: "Rest is productive when it restores purpose.", author: "Nightly"),
    .init(text: "Trade perfection for presence.", author: "Nightly"),
    .init(text: "One good decision can reboot a day.", author: "Nightly"),
    .init(text: "Make your environment a teammate.", author: "Nightly"),
    .init(text: "Kindness to yourself fuels tomorrow.", author: "Nightly"),
    .init(text: "When in doubt, simplify the next step.", author: "Nightly"),
    .init(text: "Focus on the controllables.", author: "Nightly"),
    .init(text: "Momentum is built, not found.", author: "Nightly"),
    .init(text: "Let your calendar reflect your values.", author: "Nightly"),
    .init(text: "Your best is variable. Offer today’s best.", author: "Nightly"),
    .init(text: "Standards over moods.", author: "Nightly"),
    .init(text: "Leave places and people a little better.", author: "Nightly"),
    .init(text: "Quiet mornings, strong days.", author: "Nightly"),
    .init(text: "Gratitude turns enough into plenty.", author: "Nightly"),
    .init(text: "You grow in the direction of your questions.", author: "Nightly")
  ]

  /// Deterministic daily quote (changes each calendar day).
  static func quote(for date: Date = Date(), calendar: Calendar = .current) -> DailyQuote {
    let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    return all[(day - 1) % all.count]
  }
}
