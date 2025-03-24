import Foundation
import Combine
import UserNotifications

class PreinscriptionViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    @Published var email: String = ""
    
    @Published var selectedRole: String = ""
    
    @Published var errorMessage: String = ""
    
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    
    // MARK: - Propriétés privées
    
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    let availableRoles = ["Vendeur", "Admin", "Acheteur", "Gestionnaire"]
    
    // MARK: - Méthodes publiques
    
    func submitPreinscription() {
        errorMessage = ""
        isSuccess = false
        
        let model = PreinscriptionModel(email: email.trimmingCharacters(in: .whitespacesAndNewlines), 
                                       role: selectedRole)
        
        if !model.isEmailValid {
            errorMessage = "Veuillez entrer un email valide."
            return
        }
        
        if !model.isRoleValid {
            errorMessage = "Veuillez sélectionner un rôle."
            return
        }
        
        sendPreinscription(model)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    func resetForm() {
        email = ""
        selectedRole = ""
        errorMessage = ""
        isSuccess = false
    }
    
    // MARK: - Méthodes privées
    
    /// Envoie au backend
    private func sendPreinscription(_ model: PreinscriptionModel) {
        isLoading = true
        
        guard let url = URL(string: "\(baseURL)/preinscription") else {
            errorMessage = "URL invalide pour préinscription"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": model.email, "role": model.role]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if !(200...299).contains(httpResponse.statusCode) {
                        self.errorMessage = "Erreur serveur: Code \(httpResponse.statusCode)"
                        return
                    }
                }
                
                // Traitement de la réponse
                if let data = data {
                    do {
                        let response = try JSONDecoder().decode(PreinscriptionResponse.self, from: data)
                        self.isSuccess = response.success
                        
                        if !response.success {
                            self.errorMessage = response.message
                        } else {
                            self.scheduleNotification(title: "Préinscription effectuée", 
                                                     message: "Votre préinscription a été enregistrée avec succès.")
                        }
                    } catch {
                        // Si le décodage échoue, on affiche un message générique de succès
                        self.isSuccess = true
                        self.scheduleNotification(title: "Préinscription effectuée", 
                                                 message: "Votre préinscription a été enregistrée avec succès.")
                    }
                }
            }
        }.resume()
    }
    
    private func scheduleNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}