import Foundation
import Combine

/// ViewModel pour la recherche de vendeur (vue initiale)
class VendorSearchViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    /// Email du vendeur saisi par l'utilisateur
    @Published var emailVendeur: String = ""
    
    /// Message d'erreur à afficher
    @Published var errorMessage: String? = nil
    
    // MARK: - Propriétés calculées
    
    /// Vérifie si l'email est valide pour la recherche
    var isEmailValid: Bool {
        !emailVendeur.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Crée un objet VendorSearch à partir de l'email saisi
    var currentSearch: VendorSearch? {
        guard isEmailValid else { return nil }
        return VendorSearch(email: emailVendeur)
    }
    
    // MARK: - Méthodes publiques
    
    /// Réinitialise le formulaire
    func resetForm() {
        emailVendeur = ""
        errorMessage = nil
    }
    
    /// Vérifie si l'email est valide pour afficher l'historique
    func validateAndShowHistory(completion: (String) -> Void) {
        // Vérification de l'email
        guard isEmailValid else {
            errorMessage = "Veuillez entrer un email valide"
            return
        }
        
        // Vérification supplémentaire si besoin
        guard let search = currentSearch, search.hasValidEmail else {
            errorMessage = "Format d'email invalide"
            return
        }
        
        // Email valide, effacer le message d'erreur
        errorMessage = nil
        
        // Appeler la closure pour naviguer
        completion(emailVendeur)
    }
}