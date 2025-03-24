import Foundation

/// Modèle pour une demande de récupération de mot de passe
struct PasswordRecoveryRequest {
    let email: String
}

/// Réponse de l'API pour la récupération de mot de passe
struct PasswordRecoveryResponse: Codable {
    let message: String
    let success: Bool
}