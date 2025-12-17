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

  // Original, short reflections written for Nightly
  static let all: [DailyQuote] = [

    // Existing
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
    .init(text: "You grow in the direction of your questions.", author: "Nightly"),

    // NEW — calm, reflective, recovery-friendly
    .init(text: "Today does not require everything from you.", author: "Nightly"),
    .init(text: "Slow progress is still progress.", author: "Nightly"),
    .init(text: "Peace comes from fewer, clearer choices.", author: "Nightly"),
    .init(text: "You can begin again without erasing yesterday.", author: "Nightly"),
    .init(text: "Stability is built through small promises kept.", author: "Nightly"),
    .init(text: "Awareness is already a form of change.", author: "Nightly"),
    .init(text: "Some days are about maintenance, not growth.", author: "Nightly"),
    .init(text: "You don’t have to solve your whole life tonight.", author: "Nightly"),
    .init(text: "Calm is a skill you can practice.", author: "Nightly"),
    .init(text: "Showing up counts, even quietly.", author: "Nightly"),
    .init(text: "Progress is rarely loud.", author: "Nightly"),
    .init(text: "Breathe first. Decide second.", author: "Nightly"),
    .init(text: "You are not behind—just becoming.", author: "Nightly"),
    .init(text: "Less pressure invites better choices.", author: "Nightly"),
    .init(text: "Your nervous system deserves gentleness.", author: "Nightly"),
    .init(text: "Healing is not linear, and that’s okay.", author: "Nightly"),
    .init(text: "Today can be simple and still be enough.", author: "Nightly"),
    .init(text: "The next right thing is rarely dramatic.", author: "Nightly"),
    .init(text: "You are allowed to move at your own pace.", author: "Nightly"),
    .init(text: "Quiet consistency outlasts motivation.", author: "Nightly"),
    .init(text: "Not everything needs a reaction.", author: "Nightly"),
    .init(text: "Safety comes from routine and honesty.", author: "Nightly"),
    .init(text: "You can choose steadiness over urgency.", author: "Nightly"),
    .init(text: "This moment does not define the whole day.", author: "Nightly"),
    .init(text: "Gentle structure creates freedom.", author: "Nightly"),
    .init(text: "You are building something even on slow days.", author: "Nightly"),
    .init(text: "Presence is more useful than pressure.", author: "Nightly"),
    .init(text: "You don’t need to earn rest.", author: "Nightly"),
    .init(text: "Clarity grows when you slow the noise.", author: "Nightly")
  ]

  /// Deterministic daily quote (changes each calendar day).
  static func quote(for date: Date = Date(), calendar: Calendar = .current) -> DailyQuote {
    let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
    return all[(day - 1) % all.count]
  }
}
