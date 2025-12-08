import SwiftUI

struct ContentView: View {
  @EnvironmentObject var store: NightlyStore

  @State private var selection: MenuItem = .home
  @State private var isMenuOpen: Bool = false

  var body: some View {
    NavigationStack {
      ZStack {
        // Main content
        mainContent
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Color(.systemBackground))

        // Dim background when menu is open
        if isMenuOpen {
          Color.black.opacity(0.3)
            .ignoresSafeArea()
            .zIndex(1)
            .onTapGesture {
              withAnimation(.easeInOut(duration: 0.25)) {
                isMenuOpen = false
              }
            }
        }

        // Right-side slide-out menu
        SideMenuRight(isOpen: $isMenuOpen, selection: $selection)
          .zIndex(2)
      }
      .navigationTitle(navigationTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            withAnimation(.easeInOut(duration: 0.25)) {
              isMenuOpen.toggle()
            }
          } label: {
            Image(systemName: "line.3.horizontal")
              .font(.system(size: 20, weight: .medium))
              .padding(12)                 // bigger tap target on device
              .contentShape(Rectangle())
          }
          .accessibilityLabel("Menu")
        }
      }
    }
  }

  // MARK: - Main content by selection

  @ViewBuilder
  private var mainContent: some View {
    switch selection {
    case .home:
      HomeView()
    case .new:
      NewNightlyView()
    case .history:
      HistoryView()
    case .sobriety:
      SobrietyCounterView()
    case .onAwakening:
      OnAwakeningView()
    case .serenity:
      SerenityPrayerView()
    }
  }

  private var navigationTitle: String {
    switch selection {
    case .home:
      return ""                // clean top for the home screen
    default:
      return selection.rawValue
    }
  }
}

#Preview {
  ContentView()
    .environmentObject(NightlyStore())
}
