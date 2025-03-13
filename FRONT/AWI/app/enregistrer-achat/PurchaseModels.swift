import Foundation

struct Purchase: Codable {
    var id_stock: Int
    var quantite_vendu: Int
}

struct PurchaseResponse: Codable {
    let success: Bool
    let message: String
}