import Foundation
import Combine
import UserNotifications

/// ViewModel pour gérer l'enregistrement d'un achat
class EnregistrerAchatViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Données du formulaire
    @Published var idStock: String = ""
    @Published var quantiteVendue: String = ""
    
    /// États de l'interface
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    /// Vérification de la validité du formulaire
    var isFormValid: Bool {
        !idStock.trimmingCharacters(in: .whitespaces).isEmpty &&
        !quantiteVendue.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Méthodes publiques
    
    /// Confirme l'enregistrement de l'achat
    func confirmerAchat() {
        // Validation des champs
        if !isFormValid {
            errorMessage = "Veuillez remplir tous les champs obligatoires."
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "\(baseURL)/enregistrer-achat") else {
            errorMessage = "URL invalide"
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        // Préparation des données pour l'API
        let body: [String: Any] = [
            "id_stock": idStock,
            "quantite_vendu": quantiteVendue
        ]
        
        // Configuration de la requête
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Envoi de la requête
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    self.scheduleLocalNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                guard let data = data,
                      let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let message = responseJSON["message"] as? String else {
                    self.errorMessage = "Réponse invalide du serveur"
                    self.scheduleLocalNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                self.isSuccess = true
                self.scheduleLocalNotification(title: "Succès", message: message)
                self.resetForm()
            }
        }.resume()
    }
    
    /// Réinitialise le formulaire après succès
    func resetForm() {
        idStock = ""
        quantiteVendue = ""
        errorMessage = ""
    }
    
    /// Programme une notification locale
    func scheduleLocalNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Demande l'autorisation pour les notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}