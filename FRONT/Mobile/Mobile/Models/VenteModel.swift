import Foundation

/// Modèle de vente adapté au JSON renvoyé par le backend
struct Vente: Identifiable, Decodable {
    let id: UUID
    let nomJeu: String
    let quantiteVendue: Int
    let prixUnit: Double
    let vendeurPaye: Bool
    let sommeTotaleDue: Double

    enum CodingKeys: String, CodingKey {
        case nomJeu = "nom_jeu"
        case quantiteVendue = "Quantite_vendu"
        case prixUnit = "Prix_unit"
        case vendeurPaye = "vendeur_paye"
        case sommeTotaleDue = "Somme_total_du"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nomJeu = try container.decode(String.self, forKey: .nomJeu)
        self.quantiteVendue = try container.decode(Int.self, forKey: .quantiteVendue)
        self.prixUnit = try container.decode(Double.self, forKey: .prixUnit)
        // Décoder comme Int et convertir en Bool
        let vendeurPayeInt = try container.decode(Int.self, forKey: .vendeurPaye)
        self.vendeurPaye = (vendeurPayeInt == 1)
        self.sommeTotaleDue = try container.decode(Double.self, forKey: .sommeTotaleDue)
        self.id = UUID() // Génère un identifiant unique pour chaque instance
    }
}