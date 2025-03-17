import Foundation

struct Game: Identifiable, Hashable {
    var id: Int { id_stock }
    let id_stock: Int
    let nom_jeu: String
    let Prix_unit: Double
    var Quantite_actuelle: Int
    
    // UI state
    var isSelected: Bool = false
}

struct WithdrawalRequest: Encodable {
    let id_stock: Int
    let nombre_checkbox_selectionne_cet_id: Int
}