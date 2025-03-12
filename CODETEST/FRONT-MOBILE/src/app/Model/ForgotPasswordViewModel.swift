import Foundation
import Combine

class ForgotPasswordViewModel: ObservableObject {
    // Form fields
    @Published var email = ""
    
    // Validation errors
    @Published var emailError: String?
    @Published var errorMessage: String?
    
    // UI state
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isSuccess = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService()
    
    // Validate email
    private func validateEmail() -> Bool {
        if email.isEmpty {
            emailError = "L'email est requis"
            return false
        } else if !isValidEmail(email) {
            emailError = "Format d'email invalide"
            return false
        } else {
            emailError = nil
            return true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func resetPassword() {
        // Clear previous errors
        errorMessage = nil
        
        guard validateEmail() else {
            errorMessage = "Veuillez entrer une adresse email valide."
            return
        }
        
        isLoading = true
        
        authService.requestPasswordReset(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.showError(message: "Erreur lors de la demande: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                if response.success {
                    self.showSuccess(title: "Email envoyé", message: response.message)
                } else {
                    self.showError(message: response.message)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showError(message: String) {
        alertTitle = "Erreur"
        alertMessage = message
        showAlert = true
        isSuccess = false
    }
    
    private func showSuccess(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
        isSuccess = true
    }
}

// Add this to AuthService.swift
extension AuthService {
    struct PasswordResetResponse: Decodable {
        let success: Bool
        let message: String
    }
    
    func requestPasswordReset(email: String) -> AnyPublisher<PasswordResetResponse, Error> {
        guard let url = URL(string: "\(baseURL)/request-password-reset") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PasswordResetResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}