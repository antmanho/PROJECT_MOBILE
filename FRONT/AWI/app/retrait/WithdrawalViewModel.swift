import Foundation
import SwiftUI
import Combine

class WithdrawalViewModel: ObservableObject {
    @Published var emailParticulier: String = ""
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isValid: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up email validation
        $emailParticulier
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { email in
                return !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
    }
    
    func validateForm() -> Bool {
        if emailParticulier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Veuillez entrer un email."
            showError = true
            return false
        }
        
        return true
    }
    
    func resetError() {
        showError = false
        errorMessage = ""
    }
}