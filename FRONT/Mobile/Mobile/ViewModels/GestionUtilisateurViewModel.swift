import Foundation
import Combine
import UserNotifications

/// ViewModel pour la gestion des utilisateurs
class GestionUtilisateurViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Liste des utilisateurs
    @Published var users: [User] = []
    
    /// Texte de recherche pour le filtrage
    @Published var searchText: String = ""
    
    /// États d'interface
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    /// Utilisateurs filtrés selon le texte de recherche
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { 
                $0.email.lowercased().contains(searchText.lowercased()) ||
                $0.nom.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // MARK: - Initialisation
    
    init() {
        // On peut lancer le chargement des utilisateurs dès l'initialisation si nécessaire
    }
    
    // MARK: - Méthodes publiques
    
    /// Récupère la liste des utilisateurs depuis l'API
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/users") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors de la récupération des utilisateurs: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    return
                }
                
                do {
                    let decodedUsers = try JSONDecoder().decode([User].self, from: data)
                    self.users = decodedUsers
                } catch {
                    self.errorMessage = "Erreur de décodage des utilisateurs: \(error.localizedDescription)"
                    print("Détail de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    /// Met à jour un utilisateur dans la liste locale
    func updateUser(id: Int, field: String, value: String) {
        if let index = users.firstIndex(where: { $0.id == id }) {
            switch field {
            case "email":
                users[index].email = value
            case "password":
                users[index].password = value
            case "nom":
                users[index].nom = value
            case "telephone":
                users[index].telephone = value
            case "adresse":
                users[index].adresse = value
            case "role":
                users[index].role = value
            default:
                break
            }
        }
    }
    
    /// Sauvegarde les modifications sur tous les utilisateurs
    func saveChanges() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/users") else {
            errorMessage = "URL invalide pour sauvegarde"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(users)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Erreur lors de l'encodage des utilisateurs: \(error.localizedDescription)"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors de la sauvegarde: \(error.localizedDescription)"
                    self.scheduleLocalNotification(title: "Erreur", message: self.errorMessage ?? "")
                    return
                }
                
                // Analyse de la réponse si disponible
                if let data = data,
                   let response = try? JSONDecoder().decode(UserResponse.self, from: data) {
                    if response.success {
                        self.successMessage = response.message
                        self.scheduleLocalNotification(title: "Succès", message: self.successMessage ?? "Utilisateurs mis à jour avec succès")
                    } else {
                        self.errorMessage = response.message
                        self.scheduleLocalNotification(title: "Erreur", message: self.errorMessage ?? "")
                    }
                } else {
                    self.successMessage = "Utilisateurs mis à jour avec succès"
                    self.scheduleLocalNotification(title: "Succès", message: self.successMessage ?? "")
                }
            }
        }.resume()
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
}