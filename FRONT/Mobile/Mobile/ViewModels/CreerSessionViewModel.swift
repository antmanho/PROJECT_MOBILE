import Foundation
import Combine
import UserNotifications

/// ViewModel pour gérer la création d'une session
class CreerSessionViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Données du formulaire
    @Published var nomSession: String = ""
    @Published var adresseSession: String = ""
    @Published var dateDebut = Date()
    @Published var dateFin = Date()
    @Published var fraisDepotFixe: String = ""
    @Published var fraisDepotPercent: String = ""
    @Published var descriptionSession: String = ""
    
    /// États d'interface utilisateur
    @Published var showOptionalFields: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    
    /// Résultat de la création (session créée)
    @Published var createdSession: Session? = nil
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    /// Vérification de la validité du formulaire
    var isFormValid: Bool {
        !nomSession.trimmingCharacters(in: .whitespaces).isEmpty &&
        !adresseSession.trimmingCharacters(in: .whitespaces).isEmpty &&
        !fraisDepotFixe.trimmingCharacters(in: .whitespaces).isEmpty &&
        !fraisDepotPercent.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Méthodes publiques
    
    /// Crée une nouvelle session sur le serveur
    func creerSession() {
        // Validation des champs obligatoires
        if !isFormValid {
            errorMessage = "Veuillez remplir tous les champs obligatoires."
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "\(baseURL)/creer-session") else {
            errorMessage = "URL invalide"
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        // Préparation des données pour l'API
        let formatter = configureDateFormatter()
        let body = prepareRequestBody(formatter: formatter)
        
        // Configuration de la requête
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Exécution de la requête
        executeRequest(request)
    }
    
    /// Réinitialise tous les champs du formulaire
    func resetForm() {
        nomSession = ""
        adresseSession = ""
        dateDebut = Date()
        dateFin = Date()
        fraisDepotFixe = ""
        fraisDepotPercent = ""
        descriptionSession = ""
        errorMessage = ""
        createdSession = nil
    }
    
    /// Planifie une notification locale
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
    
    // MARK: - Méthodes privées
    
    /// Configure le formateur de date pour le format MySQL
    private func configureDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Format pour DATETIME MySQL
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
        return formatter
    }
    
    /// Prépare le corps de la requête
    private func prepareRequestBody(formatter: DateFormatter) -> [String: Any] {
        // Conversion des valeurs numériques
        let fraisFixeValue = Double(fraisDepotFixe) ?? 0
        let fraisPercentValue = Double(fraisDepotPercent) ?? 0
        
        return [
            "Nom_session": nomSession,
            "adresse_session": adresseSession,
            "date_debut": formatter.string(from: dateDebut),
            "date_fin": formatter.string(from: dateFin),
            "Frais_depot_fixe": fraisFixeValue,
            "Frais_depot_percent": fraisPercentValue,
            "Description": descriptionSession
        ]
    }
    
    /// Exécute la requête HTTP
    private func executeRequest(_ request: URLRequest) {
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    self.scheduleLocalNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                guard let data = data,
                      let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.errorMessage = "Réponse invalide du serveur"
                    self.scheduleLocalNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                // Vérification du succès de la requête
                if let success = responseJSON["success"] as? Bool, success,
                   let message = responseJSON["message"] as? String {
                    
                    // Si on a reçu un ID de session dans la réponse, on peut créer un objet Session
                    if let sessionId = responseJSON["id_session"] as? Int {
                        // Création d'un objet Session à partir des données du formulaire
                        let newSession = Session(
                            id: sessionId,
                            nomSession: self.nomSession,
                            adresseSession: self.adresseSession,
                            dateDebut: self.dateDebut,
                            dateFin: self.dateFin,
                            fraisDepotFixe: Double(self.fraisDepotFixe) ?? 0,
                            fraisDepotPercent: Double(self.fraisDepotPercent) ?? 0,
                            descriptionSession: self.descriptionSession
                        )
                        self.createdSession = newSession
                    }
                    
                    self.isSuccess = true
                    self.scheduleLocalNotification(title: "Succès", message: message)
                    self.resetForm()
                } else {
                    let message = responseJSON["message"] as? String ?? "Erreur inconnue"
                    self.errorMessage = message
                    self.scheduleLocalNotification(title: "Erreur", message: message)
                }
            }
        }.resume()
    }
}