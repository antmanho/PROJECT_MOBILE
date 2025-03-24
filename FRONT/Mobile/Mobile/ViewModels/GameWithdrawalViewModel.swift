import Foundation
import Combine
import UserNotifications

/// ViewModel pour la gestion des retraits de jeux
class GameWithdrawalViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    @Published var games: [GameWithdrawal] = []
    
    @Published var errorMessage: String = ""
    
    @Published var isLoading: Bool = false
    
    // MARK: - Propriétés privées
    
    private let email: String
    
    private let baseURL = BaseUrl.lien
    
    // MARK: - Initialisation
    
    init(email: String) {
        self.email = email
    }
    
    // MARK: - Propriétés calculées
    
    var hasSelectedGames: Bool {
        games.contains(where: { $0.isSelected })
    }
    
    // MARK: - Méthodes publiques
    
    // Récupère les jeux disponibles pour retrait
    func fetchGames() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "\(baseURL)/retrait-liste/\(email)") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors du chargement: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    return
                }
                
                do {
                    let decodedGames = try JSONDecoder().decode([GameWithdrawal].self, from: data)
                    self.games = decodedGames
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                    print("Détails de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    // Retire les jeux sélectionnés
    func withdrawSelectedGames() {
        if !hasSelectedGames {
            errorMessage = "Veuillez sélectionner au moins un jeu à retirer."
            scheduleNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        errorMessage = ""
        isLoading = true
        
        let selectedGames = games.filter { $0.isSelected }
        let group = DispatchGroup()
        
        for game in selectedGames {
            group.enter()
            withdrawGame(game) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            // Réinitialisation de la sélection
            for index in self.games.indices {
                self.games[index].isSelected = false
            }
            
            self.scheduleNotification(title: "Succès", 
                                    message: "Les jeux sélectionnés ont été retirés avec succès.")
            self.fetchGames() // Recharge la liste
            self.isLoading = false
        }
    }
    
    func toggleSelection(for index: Int) {
        guard index < games.count else { return }
        games[index].isSelected.toggle()
    }
    
    // MARK: - Méthodes privées
    
    private func withdrawGame(_ game: GameWithdrawal, completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURL)/retrait") else {
            errorMessage = "URL invalide pour retrait"
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "id_stock": game.stockId,
            "nombre_checkbox_selectionne_cet_id": 1
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Erreur lors du retrait: \(error.localizedDescription)"
                }
            }
            completion()
        }.resume()
    }
    
    func scheduleNotification(title: String, message: String) {
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
}