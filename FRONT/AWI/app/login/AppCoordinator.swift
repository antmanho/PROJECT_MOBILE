import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var currentRoute: AppRoute = .login
    private var cancellables = Set<AnyCancellable>()
    
    enum AppRoute {
        case login
        case menu
        case specific(String)
    }
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: .loginSuccessful)
            .sink { [weak self] notification in
                if let redirectUrl = notification.userInfo?["redirectUrl"] as? String {
                    switch redirectUrl {
                    case "/menu":
                        self?.currentRoute = .menu
                    default:
                        self?.currentRoute = .specific(redirectUrl)
                    }
                } else {
                    self?.currentRoute = .menu
                }
            }
            .store(in: &cancellables)
    }
}

// Root view using the coordinator
struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationView {
            ZStack {
                switch coordinator.currentRoute {
                case .login:
                    LoginView()
                case .menu:
                    MenuView()
                case .specific(let route):
                    SpecificRouteView(route: route)
                }
            }
        }
        .environmentObject(coordinator)
    }
}

// Placeholder views for navigation destinations
struct MenuView: View {
    var body: some View {
        Text("Menu Principal")
            .navigationTitle("Menu")
    }
}

struct SpecificRouteView: View {
    let route: String
    
    var body: some View {
        Text("Route spécifique: \(route)")
            .navigationTitle(route)
    }
}