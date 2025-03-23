import Foundation
import Combine
import UserNotifications

/// ViewModel pour la gestion des sessions
class ModificationSessionViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Liste des sessions
    @Published var sessions: [SessionMod] = []
    
    /// Texte de recherche pour le filtrage
    @Published var searchText: String = ""
    
    /// Message d'erreur
    @Published var errorMessage: String = ""
    
    /// État de chargement
    @Published var isLoading: Bool = false
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    /// Sessions filtrées selon le texte de recherche
    var filteredSessions: [SessionMod] {
        if searchText.isEmpty {
            return sessions
        } else {
            return sessions.filter { $0.nom.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    /// Formatter pour les nombres décimaux
    static var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // MARK: - Méthodes publiques
    
    /// Binding helper pour un champ String
    func binding(for session: SessionMod, keyPath: WritableKeyPath<SessionMod, String>) -> Binding<String> {
        Binding<String>(
            get: { session[keyPath: keyPath] },
            set: { newValue in
                if let i = self.sessions.firstIndex(where: { $0.id == session.id }) {
                    self.sessions[i][keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    /// Binding helper pour un champ Date
    func dateBinding(for session: SessionMod, keyPath: WritableKeyPath<SessionMod, Date>) -> Binding<Date> {
        Binding<Date>(
            get: { session[keyPath: keyPath] },
            set: { newDate in
                if let i = self.sessions.firstIndex(where: { $0.id == session.id }) {
                    self.sessions[i][keyPath: keyPath] = newDate
                }
            }
        )
    }
    
    /// Binding helper pour un champ Double
    func doubleBinding(for session: SessionMod, keyPath: WritableKeyPath<SessionMod, Double>) -> Binding<Double> {
        Binding<Double>(
            get: { session[keyPath: keyPath] },
            set: { newValue in
                if let i = self.sessions.firstIndex(where: { $0.id == session.id }) {
                    self.sessions[i][keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    /// Binding helper pour un champ Double optionnel
    func optionalDoubleBinding(for session: SessionMod, keyPath: WritableKeyPath<SessionMod, Double?>) -> Binding<Double?> {
        Binding<Double?>(
            get: { session[keyPath: keyPath] },
            set: { newValue in
                if let i = self.sessions.firstIndex(where: { $0.id == session.id }) {
                    self.sessions[i][keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    /// Récupère les sessions depuis l'API
    func fetchSessions() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "\(baseURL)/api/sessions") else {
            errorMessage = "URL invalide pour sessions"
            scheduleNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors du chargement des sessions: \(error)"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue pour les sessions"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                // Affichage du JSON brut pour vérifier le format
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON reçu: \(jsonString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    let isoFormatter = ISO8601DateFormatter()
                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    decoder.dateDecodingStrategy = .custom { decoder in
                        let container = try decoder.singleValueContainer()
                        let dateStr = try container.decode(String.self)
                        if let date = isoFormatter.date(from: dateStr) {
                            return date
                        }
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
                    }
                    
                    let decodedSessions = try decoder.decode([SessionMod].self, from: data)
                    self.sessions = decodedSessions
                } catch {
                    self.errorMessage = "Erreur de décodage des sessions: \(error)"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                }
            }
        }.resume()
    }
    
    /// Vérifie la validité des sessions et les sauvegarde
    func validateAndSaveChanges() {
        errorMessage = ""
        
        // Validation des champs obligatoires pour chaque session
        for session in sessions {
            if session.hasEmptyRequiredFields {
                errorMessage = "Tous les champs obligatoires (Nom, Adresse) doivent être remplis."
                scheduleNotification(title: "Erreur", message: errorMessage)
                return
            }
        }
        
        saveChanges()
    }
    
    /// Sauvegarde les modifications via une requête PUT
    private func saveChanges() {
        isLoading = true
        
        guard let url = URL(string: "\(baseURL)/api/sessions") else {
            errorMessage = "URL invalide pour sauvegarde"
            scheduleNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(sessions)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Erreur lors de l'encodage des sessions: \(error)"
            scheduleNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    self.scheduleNotification(title: "Erreur", message: self.errorMessage)
                    return
                }
                
                self.scheduleNotification(title: "Succès", message: "Sessions mises à jour avec succès")
                self.errorMessage = ""
                // Recharger les sessions après mise à jour
                self.fetchSessions()
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
    
    /// Demande l'autorisation pour les notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
}