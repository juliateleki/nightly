//
//  Mood.swift
//  nightly
//
//  Updated: Mood enum for 5-point scale with emoji + label
//

import Foundation

/// 5-point mood scale mapped to emojis; Codable for JSON storage
public enum Mood: Int, CaseIterable, Identifiable, Codable {
  case veryBad = 1
  case bad = 2
  case neutral = 3
  case good = 4
  case veryGood = 5

  public var id: Int { rawValue }

  public var emoji: String {
    switch self {
    case .veryBad: return "😖"
    case .bad: return "😕"
    case .neutral: return "😐"
    case .good: return "🙂"
    case .veryGood: return "😄"
    }
  }

  public var label: String {
    switch self {
    case .veryBad: return "Very Bad"
    case .bad: return "Bad"
    case .neutral: return "Neutral"
    case .good: return "Good"
    case .veryGood: return "Very Good"
    }
  }
}
