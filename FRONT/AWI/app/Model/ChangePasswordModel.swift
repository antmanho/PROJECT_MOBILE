import SwiftUI
import Combine

class ChangePasswordViewModel: ObservableObject {
    // Form fields
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmNewPassword = ""
    
    // Validation errors
    @Published var currentPasswordError: String?
    @Published var newPasswordError: String?
    @Published var confirmNewPasswordError: String?
    @Published var errorMessage: String?
    
    // UI state
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isSuccess = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService()
    
    // Validate form fields
    private func validateForm() -> Bool {
        var isValid = true
        
        // Current password validation
        if currentPassword.isEmpty {
            currentPasswordError = "Le mot de passe actuel est requis"
            isValid = false
        } else {
            currentPasswordError = nil
        }
        
        // New password validation
        if newPassword.isEmpty {
            newPasswordError = "Le nouveau mot de passe est requis"
            isValid = false
        } else {
            newPasswordError = nil
        }
        
        // Confirm password validation
        if confirmNewPassword.isEmpty {
            confirmNewPasswordError = "La confirmation du mot de passe est requise"
            isValid = false
        } else if newPassword != confirmNewPassword {
            confirmNewPasswordError = "Les mots de passe ne correspondent pas"
            isValid = false
        } else {
            confirmNewPasswordError = nil
        }
        
        return isValid
    }
    
    func changePassword() {
        // Clear previous errors
        errorMessage = nil
        
        guard validateForm() else {
            errorMessage = "Veuillez remplir tous les champs correctement."
            return
        }
        
        isLoading = true
        
        authService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.showError(message: "Erreur lors du changement de mot de passe: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] (response: ChangePasswordResponse) in
                self?.isLoading = false
                if response.success {
                    self?.showSuccess(title: "Succès", message: "Mot de passe modifié avec succès")
                } else {
                    self?.showError(message: response.message)
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
