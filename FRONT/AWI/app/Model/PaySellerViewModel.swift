// en anglais c'est plus classe

import Foundation
import SwiftUI
import Combine

class PaySellerViewModel: ObservableObject {
    @Published var sellerEmail: String = ""
    
    // Validation state
    @Published var isValid: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up email validation
        $sellerEmail
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { email in
                return self.isValidEmail(email)
            }
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }
    
    func submitSellerEmail() -> Bool {
        // Clear previous errors
        showError = false
        errorMessage = ""
        
        // Validate email
        if sellerEmail.isEmpty {
            errorMessage = "Veuillez entrer l'email du vendeur."
            showError = true
            return false
        }
        
        if !isValidEmail(sellerEmail) {
            errorMessage = "Veuillez entrer une adresse email valide."
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}