import Foundation

struct Product: Identifiable, Decodable {
    let id: Int
    let nom_jeu: String
    let editeur: String?
    let prix_unit: Double
    let quantite_deposee: Int
    let quantite_vendu: Int
    let est_en_vente: Bool
    let description: String?
    let image: String?
    
    // Computed properties
    var quantiteRestante: Int {
        quantite_deposee - quantite_vendu
    }
    
    var imageURL: URL? {
        if let imageString = image {
            return URL(string: imageString.starts(with: "http") ? imageString : "http://localhost:3000/\(imageString)")
        }
        return nil
    }
    
    // Default image for when no image is available
    var fallbackImageName: String {
        "board-game-placeholder"
    }
}