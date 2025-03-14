// SellerPaymentModels.swift

import Foundation

struct SaleItem: Identifiable, Codable {
    var id: Int
    var nom_jeu: String
    var Quantite_vendu: Int
    var Prix_unit: Double
    var vendeur_paye: Bool
    var email_vendeur: String
    var Somme_total_du: Double?
}

struct PaySellerResponse: Codable {
    let success: Bool
    let message: String
}