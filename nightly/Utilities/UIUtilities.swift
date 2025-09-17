//
//  UIUtilities.swift
//  nightly
//
//  Created by Julia Teleki on 9/17/25.
//

import SwiftUI

// Dismiss keyboard helper (no-op on macOS)
func endEditing() {
  #if canImport(UIKit)
  UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  #endif
}
