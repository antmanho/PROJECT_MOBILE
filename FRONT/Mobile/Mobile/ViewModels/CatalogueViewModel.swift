import Foundation
import Combine
import SwiftUI

class CatalogueViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var games: [Game] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Constants
    let baseImageURL = BaseUrl.lien
    
    // MARK: - Computed Properties
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return games
        } else {
            return games.filter { $0.nomJeu.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // MARK: - Initialization
    init(initialGames: [Game] = []) {
        self.games = initialGames
    }
    
    // MARK: - Data Fetching
    func fetchCatalogue() {
        // If we already have games (passed from parent), don't fetch
        guard games.isEmpty else { return }
        
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.loadMockData()
            return
        }
        #endif
        
        guard let url = URL(string: "\(baseImageURL)/api/envente") else {
            self.errorMessage = "URL invalide"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Erreur lors du chargement du catalogue: \(error.localizedDescription)"
                    print("Erreur réseau: \(error)")
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Aucune donnée reçue"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let catalogue = try decoder.decode(CatalogueResponse.self, from: data)
                    self?.games = catalogue.results
                } catch {
                    self?.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                    print("Détails de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    // MARK: - Helper Methods
    private func loadMockData() {
        self.games = [
            Game(id: 1, nomJeu: "Jeu Exemple 1", prixUnit: 10, photoPath: "/IMAGE/Cluedo.JPG", 
                 fraisDepotFixe: 5, fraisDepotPercent: 10, prixFinal: 15, estEnVente: true),
            Game(id: 2, nomJeu: "Jeu Exemple 2", prixUnit: 20, photoPath: "/images/game2.jpg", 
                 fraisDepotFixe: 7, fraisDepotPercent: 12, prixFinal: 25, estEnVente: true)
        ]
    }
    
    func clearSearch() {
        searchText = ""
    }
}