import Foundation

struct SessionRequest: Codable {
    var email_connecte: String = ""
    var Nom_session: String = ""
    var adresse_session: String = ""
    var date_debut: String = ""
    var date_fin: String = ""
    var Frais_depot_fixe: Double = 0
    var Frais_depot_percent: Double = 0
    var Description: String = ""
}