import Foundation
import Combine
import SwiftUI

class GameDepositViewModel: ObservableObject {
    // Form fields
    @Published var selectedSessionId: String = ""
    @Published var emailVendeur: String = ""
    @Published var nomJeu: String = ""
    @Published var quantiteDeposee: String = ""
    @Published var prixUnit: String = ""
    @Published var isInSale: Bool = false
    @Published var isPaye: Bool = false
    @Published var editeur: String = ""
    @Published var description: String = ""
    @Published var imageData: Data? = nil
    
    // UI state
    @Published var sessions: [Session] = []
    @Published var selectedSession: Session? = nil
    @Published var showOptionalFields = false
    @Published var showNotification = false
    @Published var notificationMessage = ""
    @Published var notificationType: NotificationType = .success
    @Published var isLoading = false
    
    // Form validation
    @Published var fieldError: String? = nil
    @Published var paymentError: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let gestionnaireService = GestionnaireService()
    
    enum NotificationType {
        case success, error
    }
    
    init() {
        loadSessions()
    }
    
    // MARK: - Public Methods
    
    func loadSessions() {
        isLoading = true
        gestionnaireService.fetchAllSessions()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.showError("Erreur lors du chargement des sessions: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] sessions in
                    self?.sessions = sessions
                }
            )
            .store(in: &cancellables)
    }
    
    func onSessionChange() {
        guard !selectedSessionId.isEmpty else {
            selectedSession = nil
            return
        }
        
        isLoading = true
        gestionnaireService.fetchSessionInfo(selectedSessionId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.showError("Erreur lors de la récupération des infos session: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] session in
                    self?.selectedSession = session
                }
            )
            .store(in: &cancellables)
    }
    
    func setImage(_ image: UIImage?) {
        imageData = image?.jpegData(compressionQuality: 0.8)
    }
    
    func toggleOptionalFields() {
        showOptionalFields.toggle()
    }
    
    func closeNotification() {
        showNotification = false
    }
    
    func onSubmit() {
        // Reset errors
        fieldError = nil
        paymentError = nil
        
        // Validate email
        let emailPattern = "[^\\s@]+@[^\\s@]+\\.[^\\s@]+"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        if !emailPredicate.evaluate(with: emailVendeur) {
            fieldError = "Veuillez entrer une adresse email valide."
            return
        }
        
        // Validate required fields
        if emailVendeur.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           nomJeu.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           selectedSessionId.isEmpty ||
           quantiteDeposee.isEmpty || Int(quantiteDeposee) ?? 0 <= 0 ||
           prixUnit.isEmpty || Double(prixUnit) ?? 0 <= 0 {
            
            fieldError = "Tous les champs doivent être remplis correctement."
            return
        }
        
        // Validate payment
        if !isPaye {
            paymentError = "La case \"Payé\" doit être cochée avant l'envoi."
            return
        }
        
        // Submit form
        isLoading = true
        
        gestionnaireService.submitDeposit(
            sessionId: selectedSessionId,
            emailVendeur: emailVendeur,
            nomJeu: nomJeu,
            prixUnit: Double(prixUnit) ?? 0,
            quantiteDeposee: Int(quantiteDeposee) ?? 0,
            estEnVente: isInSale,
            editeur: editeur,
            description: description,
            imageData: imageData
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.showError("Erreur lors de l'envoi des données: \(error.localizedDescription)")
                }
            },
            receiveValue: { [weak self] response in
                self?.notificationMessage = "Votre jeu a été déposé."
                self?.notificationType = .success
                self?.showNotification = true
                self?.resetForm()
                
                // Scroll to top (handled in the view)
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func resetForm() {
        selectedSessionId = ""
        emailVendeur = ""
        nomJeu = ""
        quantiteDeposee = ""
        prixUnit = ""
        isInSale = false
        isPaye = false
        editeur = ""
        description = ""
        imageData = nil
        selectedSession = nil
        showOptionalFields = false
    }
    
    private func showError(_ message: String) {
        notificationMessage = message
        notificationType = .error
        showNotification = true
    }
    
    // Calculate deposit fee
    var depositFee: Double {
        guard let session = selectedSession, let price = Double(prixUnit) else {
            return 0
        }
        
        return session.Frais_depot_fixe + (price * session.Frais_depot_percent / 100)
    }
}