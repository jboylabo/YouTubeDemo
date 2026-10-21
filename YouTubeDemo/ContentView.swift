import SwiftUI

extension EnvironmentValues {
    @Entry var hinge: DeviceHinge?
}

struct ContentView: View {
    @State private var hinge: DeviceHinge?

    var body: some View {
        TabView {
            Tab("ホーム", systemImage: "house.fill") {
                HomeView()
            }
            Tab("ショート", systemImage: "play.square.stack.fill") {
                ShortsView()
            }
            Tab("登録チャンネル", systemImage: "rectangle.stack.badge.play.fill") {
                SubscriptionsView()
            }
            Tab("ライブラリ", systemImage: "books.vertical.fill") {
                LibraryView()
            }
        }
        .tint(.red)
        .environment(\.hinge, hinge)
        .overlay(alignment: .topTrailing) { hingeBadge }
        .onHingeChange { _, newContext in
            hinge = newContext.hinge
        }
    }

    @ViewBuilder
    private var hingeBadge: some View {
        if let hinge {
            let status = switch hinge.status {
            case .closed: "Closed"
            case .fullyOpen: "Fully Open"
            case .partiallyOpen: "Partially Open"
            default: "Unknown"
            }
            Text("\(status) \(hinge.angle.degrees, specifier: "%.0f")°")
                .font(.caption2.monospacedDigit())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.trailing, 8)
                .allowsHitTesting(false)
        }
    }
}
