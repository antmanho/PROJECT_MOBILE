import Foundation

/// Modèle représentant un jeu pouvant être retiré
struct GameWithdrawal: Identifiable, Decodable {
    let stockId: Int
    let name: String
    let price: Double
    let currentQuantity: Int
    var isSelected: Bool = false

    var id: Int { stockId }

    enum CodingKeys: String, CodingKey {
        case stockId = "id_stock"
        case name = "nom_jeu"
        case price = "Prix_unit"
        case currentQuantity = "Quantite_actuelle"
    }
}

/// Réponse de l'API pour un retrait
struct WithdrawalResponse: Decodable {
    let success: Bool
    let message: String
}