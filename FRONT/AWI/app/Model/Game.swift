import Foundation

struct Game: Identifiable, Decodable {
    let id: Int
    let id_stock: Int
    let nom_jeu: String
    let prix_final: Double
    let photo_path: String
    let est_en_vente: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case id_stock = "id_stock"
        case nom_jeu = "nom_jeu"
        case est_en_vente = "est_en_vente"
        case prix_final = "prix_final"
        case photo_path = "photo_path"
    }
    
    // URL complète pour l'image
    var imageUrl: URL? {
        URL(string: "http://localhost:3000" + photo_path)
    }
}

// Structure pour décoder la réponse de l'API
struct CatalogueResponse: Decodable {
    let results: [Game]
}