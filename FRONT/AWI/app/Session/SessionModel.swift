import Foundation

struct Session: Identifiable, Codable {
    var id: String { id_session }
    let id_session: String
    var Nom_session: String
    var adresse_session: String
    var date_debut: String
    var date_fin: String
    var Charge_totale: Int
    var Frais_depot_fixe: Double
    var Frais_depot_percent: Double
    var Description: String
    
    // Local tracking property (not sent to server)
    var isModified: Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case id_session, Nom_session, adresse_session, date_debut, date_fin, 
             Charge_totale, Frais_depot_fixe, Frais_depot_percent, Description
    }
}

struct ApiResponse: Codable {
    let success: Bool
    let message: String
}