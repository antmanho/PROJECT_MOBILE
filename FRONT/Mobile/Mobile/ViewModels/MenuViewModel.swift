import Foundation
import SwiftUI
import Combine

class MenuViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    @Published var selectedView: String = "ConnexionView"
    
    /// Rôle de l'utilisateur actuel (était X dans le code original)
    @Published var userRole: UserRole = .invite
    @Published var activeButton: String? = "Se connecter"
    
    @Published var retraitEmail: String = ""
    @Published var payerEmail: String = ""
    @Published var bilanData: BilanGraphData? = nil
    @Published var selectedGame: Int? = nil
    @Published var catalogueGames: [Game] = []
    
    @Published var lastViewBeforeMotPasseOublie: String = "ConnexionView"
    @Published var lastViewBeforeDetailArticle: String = "CatalogueView"
    
    // MARK: - URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Initialisation
    init() {
        // Charge les jeux du catalogue au démarrage ou à tout autre moment approprié
        // loadCatalogueGames()
    }
    
    // MARK: - Méthodes de gestion de la navigation
    
    /// Change la vue sélectionnée et met à jour le bouton actif
    func navigateTo(view: String, button: String? = nil) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedView = view
            if let button = button {
                activeButton = button
            }
        }
    }
    
    /// Gère la déconnexion de l'utilisateur
    func logout() {
        withAnimation(.easeInOut(duration: 0.2)) {
            userRole = .invite
            activeButton = "Se connecter"
            selectedView = "ConnexionView"
            
            // Appel à l'API de déconnexion
            guard let url = URL(string: "\(baseURL)/deconnexion") else {
                print("URL invalide pour la déconnexion")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Erreur lors de la déconnexion : \(error)")
                    return
                }
                if let data = data,
                   let responseString = String(data: data, encoding: .utf8) {
                    print("Réponse backend : \(responseString)")
                }
            }.resume()
        }
    }
    
    /// Gère le succès de connexion
    func handleLoginSuccess(role: String) {
        userRole = UserRole.fromApiRole(role)
        activeButton = "Accueil"
        selectedView = "Accueil"
    }
    
    /// Affiche les détails d'un jeu
    func showGameDetails(gameId: Int, fromView: String) {
        selectedGame = gameId
        lastViewBeforeDetailArticle = fromView
        selectedView = "DetailArticle"
    }
    
    /// Retourne à la vue précédente depuis les détails d'un article
    func returnFromGameDetails() {
        selectedView = lastViewBeforeDetailArticle
    }
    
    // MARK: - Chargement des données
    
    /// Charge les jeux pour le catalogue
    func loadCatalogueGames() {
        guard let url = URL(string: "\(baseURL)/api/catalogue") else {
            print("URL invalide pour le catalogue")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Erreur de chargement du catalogue: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Données catalogue non reçues")
                return
            }
            
            do {
                let response = try JSONDecoder().decode(CatalogueResponse.self, from: data)
                DispatchQueue.main.async {
                    self.catalogueGames = response.results
                }
            } catch {
                print("Erreur de décodage du catalogue: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // MARK: - Propriétés calculées
    
    /// Renvoie les éléments du menu supérieur en fonction du rôle
    var topMenuItems: [String] {
        userRole.getMenuItems()
    }
    
    /// Détermine si l'utilisateur peut voir le menu "Mise en Vente"
    var canSeeMiseEnVente: Bool {
        userRole.canAccessMiseEnVente
    }
    
    /// Détermine si l'utilisateur est un invité (non connecté)
    var isGuest: Bool {
        userRole == .invite
    }
    
    /// Récupère le texte à afficher pour le rôle actuel
    var roleDisplayText: String {
        userRole.displayText
    }
    
    /// Récupère la taille de police appropriée pour le texte du rôle
    var roleFontSize: Font {
        userRole == .gestionnaire ? .caption : .body
    }
}