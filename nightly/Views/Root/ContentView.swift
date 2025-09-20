import SwiftUI

struct ContentView: View {
  @StateObject private var store = NightlyStore()
  @State private var selection: MenuItem = .new
  @State private var isMenuOpen: Bool = false

  var body: some View {
    ZStack {
      NavigationStack {
        Group {
          switch selection {
            case .new:
              NewNightlyView().navigationTitle("Nightly Inventory")
            case .history:
              HistoryView().navigationTitle("History")
            case .sobriety:
              SobrietyCounterView().navigationTitle("Sobriety Counter")
            case .onAwakening:
              OnAwakeningView().navigationTitle("On Awakening")
            case .serenity:
              SerenityPrayerView().navigationTitle("Serenity Prayer")
          }
        }
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              withAnimation(.easeInOut(duration: 0.2)) { isMenuOpen.toggle() }
            } label: { Image(systemName: "line.3.horizontal") }
            .accessibilityLabel("Menu")
          }
        }
      }

      if isMenuOpen {
        Color.black.opacity(0.25)
          .ignoresSafeArea()
          .zIndex(1)
          .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) { isMenuOpen = false }
          }
      }

      SideMenuRight(isOpen: $isMenuOpen, selection: $selection)
        .zIndex(2)
    }
    .environmentObject(store)
  }
}

#Preview {
  ContentView()
}
