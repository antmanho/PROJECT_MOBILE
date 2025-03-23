import Foundation
import Combine
import UserNotifications

/// ViewModel pour la gestion des paiements vendeur
class PayerVendeurViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Liste des ventes du vendeur
    @Published var historiqueVentes: [Vente] = []
    
    /// Message d'erreur à afficher
    @Published var errorMessage: String = ""
    
    /// Indicateur de chargement
    @Published var isLoading: Bool = false
    
    // MARK: - Propriétés privées
    
    /// Email du vendeur concerné
    private let email: String
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Initialisation
    
    /// Initialise le ViewModel avec l'email du vendeur
    init(email: String) {
        self.email = email
    }
    
    // MARK: - Propriétés calculées
    
    /// Somme totale due au vendeur
    var sommeTotale: Double {
        historiqueVentes.first?.sommeTotaleDue ?? 0
    }
    
    // MARK: - Méthodes publiques
    
    /// Récupère l'historique des ventes depuis l'API
    func fetchHistorique() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "\(baseURL)/historique-vente/\(email)") else {
            errorMessage = "URL invalide pour historique"
            scheduleNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                do {
                    let decodedVentes = try JSONDecoder().decode([Vente].self, from: data)
                    self.historiqueVentes = decodedVentes
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                    print("Détail: \(error)")
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                }
            }
        }.resume()
    }
    
    /// Envoie la requête pour payer le vendeur
    func payerVendeur() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "\(baseURL)/payer-vendeur-liste") else {
            errorMessage = "URL invalide pour payer le vendeur"
            scheduleNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors du paiement: \(error.localizedDescription)"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                if let data = data,
                   let _ = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    self.scheduleNotification(title: "Succès", message: "Le vendeur a été payé avec succès.")
                    self.fetchHistorique() // Rafraîchir les données après paiement
                }
            }
        }.resume()
    }
    
    /// Programme une notification locale
    func scheduleNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}