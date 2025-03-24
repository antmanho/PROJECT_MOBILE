import Foundation

/// Modèle représentant une session de jeux
struct Session: Codable, Identifiable {
    var id: Int
    var nomSession: String
    var adresseSession: String
    var dateDebut: Date
    var dateFin: Date
    var fraisDepotFixe: Double
    var fraisDepotPercent: Double
    var descriptionSession: String
    
    // Pour l'encodage JSON vers le serveur
    enum CodingKeys: String, CodingKey {
        case id = "id_session"
        case nomSession = "Nom_session"
        case adresseSession = "adresse_session"
        case dateDebut = "date_debut"
        case dateFin = "date_fin"
        case fraisDepotFixe = "Frais_depot_fixe"
        case fraisDepotPercent = "Frais_depot_percent"
        case descriptionSession = "Description"
    }
}

/// Structure pour la réponse de l'API
struct SessionResponse: Codable {
    let message: String
    let success: Bool
}