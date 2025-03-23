import Foundation

/// Modèle représentant un vendeur à payer
struct Vendor {
    /// Email du vendeur
    let email: String
    
    /// Vérifie si l'email a un format valide
    var hasValidEmail: Bool {
        // Expression régulière simple pour la validation d'email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}