import Foundation

/// Modèle représentant un achat
struct Achat {
    let idStock: String
    let quantiteVendue: String
}

/// Structure pour la réponse de l'API
struct AchatResponse: Codable {
    let message: String
    let success: Bool
}