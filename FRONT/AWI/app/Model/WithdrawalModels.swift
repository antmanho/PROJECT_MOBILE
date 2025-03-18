import Foundation
import Game

struct WithdrawalRequest: Encodable {
    let id_stock: Int
    let nombre_checkbox_selectionne_cet_id: Int
}