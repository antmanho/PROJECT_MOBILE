import Foundation

struct PreinscriptionModel: Codable {
    let email: String
    
    // Rôle attribué à l'utilisateur
    let role: String
    
    // Validation de l'email avc la presence du @ et du . tu vois le truc
    var isEmailValid: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    
    var isRoleValid: Bool {
        !role.isEmpty
    }
    
    var isValid: Bool {
        isEmailValid && isRoleValid
    }
}

// Réponse de l'API pour une préinscription
struct PreinscriptionResponse: Codable {
    let success: Bool
    let message: String
}