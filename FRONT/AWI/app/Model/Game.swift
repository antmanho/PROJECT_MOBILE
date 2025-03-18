import Foundation

struct Game: Identifiable, Codable, Hashable {
    // Main identifier fields
    let id: Int
    let id_stock: Int
    
    // Game details
    let nom_jeu: String
    let type: String?
    let editeur: String?
    var description: String?
    
    // Price and sales information
    let prix_final: Double
    var Prix_unit: Double { return prix_final }
    var prix: Double { return prix_final }
    
    // Status fields
    var est_en_vente: Int?  // Used in CatalogueView
    var enVente: Bool {     // Used in ManagerService
        get { return est_en_vente == 1 }
        set { est_en_vente = newValue ? 1 : 0 }
    }
    
    // Quantity tracking
    var Quantite_actuelle: Int?
    var quantite_deposee: Int?
    var quantite_vendu: Int?
    
    // Seller information
    let vendeurId: String?
    let vendeurNom: String?
    
    // Image path
    let photo_path: String?
    
    // UI state (for WithdrawalList)
    var isSelected: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, id_stock, nom_jeu, type, editeur, description
        case prix_final, Prix_unit, prix
        case est_en_vente, Quantite_actuelle, quantite_deposee, quantite_vendu
        case vendeurId, vendeurNom
        case photo_path
        // isSelected is transient and not encoded/decoded
    }
    
    // URL complète pour l'image
    var imageUrl: URL? {
        guard let path = photo_path else { return nil }
        return URL(string: "http://localhost:3000" + path)
    }
    
    // Alternative URL format used in other parts of the app
    var imageURL: URL? {
        guard let path = photo_path else { return nil }
        return URL(string: "http://localhost:3000" + path)
    }
}

// Structure pour décoder la réponse de l'API
struct CatalogueResponse: Decodable {
    let results: [Game]
}