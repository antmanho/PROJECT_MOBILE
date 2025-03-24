import Foundation

/// Type d'une notification
enum NotificationType {
    case success
    case error
}

/// Modèle représentant une session modifiable
struct SessionMod: Identifiable, Codable {
    var id: Int                // id_session
    var nom: String            // Nom_session
    var adresse: String        // adresse_session
    var dateDebut: Date        // date_debut
    var dateFin: Date          // date_fin
    var chargeTotale: Double?  // Charge_totale, optionnel
    var fraisFixe: Double      // Frais_depot_fixe
    var fraisPourcent: Double  // Frais_depot_percent
    var description: String    // Description

    enum CodingKeys: String, CodingKey {
        case id = "id_session"
        case nom = "Nom_session"
        case adresse = "adresse_session"
        case dateDebut = "date_debut"
        case dateFin = "date_fin"
        case chargeTotale = "Charge_totale"
        case fraisFixe = "Frais_depot_fixe"
        case fraisPourcent = "Frais_depot_percent"
        case description = "Description"
    }
    
    /// Vérifie si la session a des champs obligatoires vides
    var hasEmptyRequiredFields: Bool {
        nom.trimmingCharacters(in: .whitespaces).isEmpty ||
        adresse.trimmingCharacters(in: .whitespaces).isEmpty
    }
}