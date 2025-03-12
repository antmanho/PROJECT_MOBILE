import Foundation
import Combine

class CreateSessionViewModel: ObservableObject {
    @Published var session = SessionRequest()
    @Published var showOptionalFields = false
    @Published var notificationMessage: String?
    @Published var isLoading = false
    @Published var showNotification = false
    
    private let sessionService = SessionService()
    private var cancellables = Set<AnyCancellable>()
    
    // Format dates properly
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // Date objects for SwiftUI date pickers
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(86400) // +1 day
    
    // Update the string dates when Date objects change
    func updateDateStrings() {
        session.date_debut = dateFormatter.string(from: startDate)
        session.date_fin = dateFormatter.string(from: endDate)
    }
    
    func toggleOptionalFields() {
        showOptionalFields.toggle()
    }
    
    func closeNotification() {
        showNotification = false
        notificationMessage = nil
    }
    
    func createSession() {
        // Update dates
        updateDateStrings()
        
        // Validate form
        guard isFormValid() else {
            notificationMessage = "Veuillez remplir tous les champs requis."
            showNotification = true
            return
        }
        
        isLoading = true
        
        sessionService.createSession(session)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case let .failure(error) = completion {
                        self?.notificationMessage = "Erreur lors de la création de la session. Veuillez réessayer."
                        self?.showNotification = true
                        print("Error creating session: \(error)")
                    }
                },
                receiveValue: { [weak self] response in
                    self?.notificationMessage = "Session ajoutée avec succès !"
                    self?.showNotification = true
                    
                    // Reset form after success
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.resetForm()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func isFormValid() -> Bool {
        return !session.Nom_session.isEmpty &&
               !session.adresse_session.isEmpty &&
               !session.date_debut.isEmpty &&
               !session.date_fin.isEmpty
    }
    
    private func resetForm() {
        session = SessionRequest()
        startDate = Date()
        endDate = Date().addingTimeInterval(86400)
    }
}