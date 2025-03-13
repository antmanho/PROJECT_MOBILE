import Foundation

struct Session: Identifiable, Decodable {
    let id_session: String
    let Nom_session: String
    let Frais_depot_fixe: Double
    let Frais_depot_percent: Double
    
    var id: String { id_session }
}

struct DepositResponse: Decodable {
    let success: Bool
    let message: String
}