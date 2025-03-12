import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService()
    
    func login() {
        // Reset error message
        errorMessage = nil
        
        // Validate inputs
        if email.isEmpty || password.isEmpty {
            errorMessage = "Veuillez remplir tous les champs correctement."
            return
        }
        
        isLoading = true
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Erreur de connexion. Veuillez réessayer."
                    print("Erreur lors de la connexion : \(error)")
                }
            } receiveValue: { [weak self] response in
                // Handle successful response
                if response.success {
                    // Navigate to the appropriate screen based on response
                    NotificationCenter.default.post(
                        name: .loginSuccessful,
                        object: nil,
                        userInfo: ["redirectUrl": response.redirectUrl]
                    )
                } else {
                    self?.errorMessage = response.message
                }
            }
            .store(in: &cancellables)
    }
}

// Extension for notification name
extension Notification.Name {
    static let loginSuccessful = Notification.Name("loginSuccessful")
}