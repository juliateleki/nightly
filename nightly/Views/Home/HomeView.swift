import SwiftUI

struct HomeView: View {
  private let quote = DailyQuotes.quote()
  private let verticalBias: CGFloat = 80   // ⬅️ raise quote by ~80pt (tweak to taste)

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 24) {
          // Centered "Welcome" at the top
          Text("Welcome")
            .font(.largeTitle.bold())
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)

          // Spacer pushes toward vertical center
          Spacer(minLength: 0)

          // Centered quote card
          VStack(alignment: .center, spacing: 12) {
            Image(systemName: "quote.bubble")
              .imageScale(.large)
              .opacity(0.6)

            Text("“\(quote.text)”")
              .font(.title)                       // larger quote text
              .multilineTextAlignment(.center)
              .fixedSize(horizontal: false, vertical: true)

            if let author = quote.author, !author.isEmpty {
              Text("— \(author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
          }
          .padding(16)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(Color(.secondarySystemBackground))
          )
          .frame(maxWidth: 560)
          .frame(maxWidth: .infinity, alignment: .center)

          // Bottom spacer + a little fixed space to bias the quote upward
          Spacer(minLength: 0)
          Color.clear.frame(height: verticalBias)   // ⬅️ adds extra space *below* the quote
        }
        .padding()
        .frame(minHeight: proxy.size.height)        // lets Spacers take effect
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        ShareLink(item: shareText) { Image(systemName: "square.and.arrow.up") }
          .accessibilityLabel("Share Quote")
      }
    }
  }

  private var shareText: String {
    if let author = quote.author, !author.isEmpty {
      return "“\(quote.text)” — \(author)"
    }
    return "“\(quote.text)”"
  }
}

#Preview {
  NavigationStack { HomeView() } // no nav title
}
