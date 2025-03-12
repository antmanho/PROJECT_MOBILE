import SwiftUI
import Combine

// View modifier for vendor role protection
struct RequireVendorRole: ViewModifier {
    @EnvironmentObject private var authService: AuthService
    @State private var hasRole = false
    @State private var isVerifying = true
    @State private var cancellable: AnyCancellable?
    
    let destination: () -> AnyView
    
    func body(content: Content) -> some View {
        Group {
            if isVerifying {
                ProgressView("Vérification des droits d'accès...")
                    .onAppear {
                        verifyRole()
                    }
            } else if hasRole {
                content
            } else {
                destination()
            }
        }
    }
    
    private func verifyRole() {
        cancellable = authService.verifyVendorRole()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        hasRole = false
                        isVerifying = false
                    }
                },
                receiveValue: { hasAccess in
                    hasRole = hasAccess
                    isVerifying = false
                }
            )
    }
}

// View modifier for admin role protection
struct RequireAdminRole: ViewModifier {
    @EnvironmentObject private var authService: AuthService
    @State private var hasRole = false
    @State private var isVerifying = true
    @State private var cancellable: AnyCancellable?
    
    let destination: () -> AnyView
    
    func body(content: Content) -> some View {
        Group {
            if isVerifying {
                ProgressView("Vérification des droits d'accès...")
                    .onAppear {
                        verifyRole()
                    }
            } else if hasRole {
                content
            } else {
                destination()
            }
        }
    }
    
    private func verifyRole() {
        cancellable = authService.verifyAdminRole()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        hasRole = false
                        isVerifying = false
                    }
                },
                receiveValue: { hasAccess in
                    hasRole = hasAccess
                    isVerifying = false
                }
            )
    }
}

// View modifier for manager or admin role protection
struct RequireManagerOrAdminRole: ViewModifier {
    @EnvironmentObject private var authService: AuthService
    @State private var hasRole = false
    @State private var isVerifying = true
    @State private var cancellable: AnyCancellable?
    
    let destination: () -> AnyView
    
    func body(content: Content) -> some View {
        Group {
            if isVerifying {
                ProgressView("Vérification des droits d'accès...")
                    .onAppear {
                        verifyRole()
                    }
            } else if hasRole {
                content
            } else {
                destination()
            }
        }
    }
    
    private func verifyRole() {
        cancellable = authService.verifyManagerOrAdminRole()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        hasRole = false
                        isVerifying = false
                    }
                },
                receiveValue: { hasAccess in
                    hasRole = hasAccess
                    isVerifying = false
                }
            )
    }
}

// Extension to make view modifiers easy to use
extension View {
    func requireVendorRole(redirectTo destination: @escaping () -> AnyView) -> some View {
        self.modifier(RequireVendorRole(destination: destination))
    }
    
    func requireAdminRole(redirectTo destination: @escaping () -> AnyView) -> some View {
        self.modifier(RequireAdminRole(destination: destination))
    }
    
    func requireManagerOrAdminRole(redirectTo destination: @escaping () -> AnyView) -> some View {
        self.modifier(RequireManagerOrAdminRole(destination: destination))
    }
}