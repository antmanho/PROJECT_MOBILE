import Foundation
import Combine

/// ViewModel pour la gestion des détails d'un article
class DetailArticleViewModel: ObservableObject {
    /// État du produit
    @Published var product: GameDetail? = nil
    
    /// États d'interface
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    /// ID du jeu à afficher
    private let gameId: Int
    
    /// URL de base pour les appels API
    let baseURL = BaseUrl.lien
    
    /// Initialisation avec l'ID du jeu
    init(gameId: Int) {
        self.gameId = gameId
    }
    
    /// Récupère les détails du produit depuis l'API
    func fetchProductDetail() {
        guard let url = URL(string: "\(baseURL)/api/detail/\(gameId)") else {
            errorMessage = "URL invalide"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let detail = try decoder.decode(GameDetail.self, from: data)
                    self.product = detail
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                    print("Erreur détaillée: \(error)")
                }
            }
        }.resume()
    }
    
    /// Formatte un prix avec symbole €
    func formatPrice(_ price: Double) -> String {
        return String(format: "%.2f €", price)
    }
    
    /// Construit l'URL complète de l'image
    func getFullImageUrl() -> URL? {
        guard let product = product else { return nil }
        return URL(string: baseURL + product.photoPath)
    }
}