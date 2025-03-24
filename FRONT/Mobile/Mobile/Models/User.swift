import Foundation

/// Modèle représentant un utilisateur du système
struct User: Identifiable, Codable {
    let id: Int // Correspond à id_users
    var email: String
    var password: String
    var nom: String
    var telephone: String
    var adresse: String
    var role: String

    enum CodingKeys: String, CodingKey {
        case id = "id_users"
        case email
        case password = "mdp"
        case nom
        case telephone
        case adresse
        case role
    }
}

/// Structure pour les réponses API liées aux utilisateurs
struct UserResponse: Codable {
    let message: String
    let success: Bool
}