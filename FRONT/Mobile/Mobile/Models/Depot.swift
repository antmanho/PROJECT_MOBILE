import Foundation
import UIKit

/// Structure représentant un dépôt de jeu
struct Depot {
    var emailVendeur: String
    var nomJeu: String
    var prixUnit: String
    var quantiteDeposee: String
    var editeur: String
    var description: String
    var estEnVente: Bool
    var selectedSessionId: Int?
    var image: UIImage?
    
    /// Vérifie si les informations obligatoires sont remplies
    var isValid: Bool {
        return !emailVendeur.trimmingCharacters(in: .whitespaces).isEmpty &&
               !nomJeu.trimmingCharacters(in: .whitespaces).isEmpty &&
               !prixUnit.trimmingCharacters(in: .whitespaces).isEmpty &&
               !quantiteDeposee.trimmingCharacters(in: .whitespaces).isEmpty &&
               selectedSessionId != nil
    }
}