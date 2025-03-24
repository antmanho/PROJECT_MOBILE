import Foundation
import Combine

/// ViewModel pour la gestion de la mise en vente des jeux
class MiseEnVenteViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Liste des jeux
    @Published var games: [Game] = []
    
    /// Texte de recherche
    @Published var searchText: String = ""
    
    /// États d'interface
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    /// Jeux filtrés selon le texte de recherche
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return games
        } else {
            return games.filter { $0.nomJeu.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // MARK: - Méthodes publiques
    
    /// Récupère le catalogue depuis l'API
    func fetchCatalogue() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/catalogue") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors du chargement du catalogue: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let catalogue = try decoder.decode(CatalogueResponse.self, from: data)
                    self.games = catalogue.results
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                    print("Détail de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    /// Bascule l'état "en vente" d'un jeu
    func toggleEnVente(index: Int, newValue: Bool) {
        let game = filteredGames[index]
        
        guard let url = URL(string: "\(baseURL)/api/stock/\(game.id)/toggle-vente") else {
            errorMessage = "URL invalide pour la mise à jour"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["est_en_vente": newValue]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur lors de la mise à jour: \(error.localizedDescription)"
                } else {
                    if let originalIndex = self.games.firstIndex(where: { $0.id == game.id }) {
                        self.games[originalIndex].estEnVente = newValue
                    }
                }
            }
        }.resume()
    }
    
    /// Récupère l'URL complète de l'image d'un jeu
    func getFullImageURL(path: String?) -> URL? {
        guard let path = path else { return nil }
        return URL(string: baseURL + path)
    }
}