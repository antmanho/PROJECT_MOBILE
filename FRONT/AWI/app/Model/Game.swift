import Foundation

struct Game: Identifiable, Decodable {
    let id_stock: Int
    let nom_jeu: String
    let prix_final: Double
    let photo_path: String
    let est_en_vente: Int?
    
    // Propriété calculée pour conformité à Identifiable
    var id: Int { id_stock }
    
    // URL complète pour l'image
    var imageUrl: URL? {
        URL(string: "http://localhost:3000" + photo_path)
    }
}

// Structure pour décoder la réponse de l'API
struct CatalogueResponse: Decodable {
    let results: [Game]
}