import Foundation

struct BilanRequestBody: Codable {
    let bilanParticulier: Bool
    let sessionParticuliere: Bool
    let emailParticulier: String?
    let numeroSession: String?
    let chargesFixes: Double
}

struct BilanData: Codable {
    let listeX: [String]?
    let listeYSomme: [Double]?
    let listeY2Somme: [Double]?
    let listeY3Somme: [Double]?
    let totalQuantiteDeposee: Int?
    let totalQuantiteVendu: Int?
    let message: String?
}