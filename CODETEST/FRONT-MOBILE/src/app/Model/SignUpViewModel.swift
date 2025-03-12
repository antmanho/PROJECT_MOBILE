import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    // Validation errors
    @Published var emailError: String?
    @Published var passwordError: String?
    @Published var confirmPasswordError: String?
    @Published var errorMessage: String?
    
    // UI state
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isSuccess = false
    @Published var needsVerification = false
    
    // Navigation
    @Published var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case verification(email: String)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService()
    
    // Validate form fields
    private func validateForm() -> Bool {
        var isValid = true
        
        // Email validation
        if email.isEmpty {
            emailError = "L'email est requis"
            isValid = false
        } else if !isValidEmail(email) {
            emailError = "Format d'email invalide"
            isValid = false
        } else {
            emailError = nil
        }
        
        // Password validation
        if password.isEmpty {
            passwordError = "Le mot de passe est requis"
            isValid = false
        } else {
            passwordError = nil
        }
        
        // Confirm password validation
        if confirmPassword.isEmpty {
            confirmPasswordError = "La confirmation du mot de passe est requise"
            isValid = false
        } else if password != confirmPassword {
            confirmPasswordError = "Les mots de passe ne correspondent pas"
            isValid = false
        } else {
            confirmPasswordError = nil
        }
        
        return isValid
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func register() {
        // Clear previous errors
        errorMessage = nil
        
        guard validateForm() else {
            errorMessage = "Veuillez remplir tous les champs correctement."
            return
        }
        
        isLoading = true
        
        authService.register(email: email, password: password, confirmPassword: confirmPassword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.showError(message: "Erreur lors de l'inscription: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                self.isSuccess = true
                
                if response.message.contains("code de verification") {
                    self.needsVerification = true
                    self.showSuccess(title: "Vérification requise", message: response.message)
                } else {
                    self.showSuccess(title: "Inscription réussie", message: "Vous pouvez maintenant vous connecter.")
                }
            }
            .store(in: &cancellables)
    }
    
    func navigateToVerification() {
        navigationDestination = .verification(email: email)
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
    struct RegisterResponse: Decodable {
        let success: Bool
        let message: String
    }
    
    func register(email: String, password: String, confirmPassword: String) -> AnyPublisher<RegisterResponse, Error> {
        guard let url = URL(string: "\(baseURL)/register") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "new_email": email,
            "new_password": password,
            "confirm_password": confirmPassword
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: RegisterResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}