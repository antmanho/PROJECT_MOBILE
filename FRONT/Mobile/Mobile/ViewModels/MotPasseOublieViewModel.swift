import Foundation
import Combine
import UserNotifications

/// ViewModel pour la gestion de la récupération de mot de passe
class MotPasseOublieViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Email saisi par l'utilisateur
    @Published var email: String = ""
    
    /// États d'interface
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    /// Vérification si l'email est valide pour l'envoi
    var isEmailValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Méthodes publiques
    
    /// Déclenche la procédure de récupération de mot de passe
    func resetPassword() {
        guard isEmailValid else {
            errorMessage = "Veuillez entrer un email valide."
            scheduleNotification(title: "Erreur", message: errorMessage!)
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        guard let url = URL(string: "\(baseURL)/mdp_oublie") else {
            errorMessage = "URL invalide."
            scheduleNotification(title: "Erreur", message: errorMessage!)
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage!)
                    return
                }
                
                // Traitement de la réponse
                if let data = data,
                   let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = responseDict["message"] as? String {
                    self.successMessage = message
                } else {
                    self.successMessage = "Un mail de récupération vous a été envoyé."
                }
                
                self.scheduleNotification(title: "Succès", message: self.successMessage!)
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
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Demande l'autorisation pour les notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}