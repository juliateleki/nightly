import SwiftUI

struct SerenityPrayerView: View {
  private let prayer = SerenityPrayer.text

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Serenity Prayer")
          .font(.title2.weight(.semibold))

        Text(prayer)
          .font(.title2)                 // ⬅️ larger than .body, still Dynamic Type friendly
          .lineSpacing(6)                // ⬅️ improves readability
          .textSelection(.enabled)
          .frame(maxWidth: 620)          // ⬅️ optional: limit line length
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding()
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        ShareLink(item: prayer) {
          Image(systemName: "square.and.arrow.up")
        }
        .accessibilityLabel("Share")
      }
    }
  }
}
