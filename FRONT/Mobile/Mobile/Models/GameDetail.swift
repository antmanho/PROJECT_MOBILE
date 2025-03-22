import Foundation

/// Modèle de données représentant les détails d'un jeu
struct GameDetail: Decodable, Identifiable {
    let id: Int               // Correspond à id_stock
    let nomJeu: String        // Correspond à nom_jeu
    let prixUnit: Double      // Correspond à Prix_unit
    let photoPath: String     // Correspond à photo_path
    let editeur: String?      // Facultatif
    let description: String?  // Facultatif
    let fraisDepotFixe: Int
    let fraisDepotPercent: Int
    let prixFinal: Double
    let estEnVente: Bool      // Converti depuis un entier (1 ou 0)
    
    /// Clés pour le décodage JSON
    private enum CodingKeys: String, CodingKey {
        case id = "id_stock"
        case nomJeu = "nom_jeu"
        case prixUnit = "Prix_unit"
        case photoPath = "photo_path"
        case editeur
        case description
        case fraisDepotFixe = "Frais_depot_fixe"
        case fraisDepotPercent = "Frais_depot_percent"
        case prixFinal = "prix_final"
        case estEnVente = "est_en_vente"
    }
    
    /// Initialisation avec décodage personnalisé
    init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       id = try container.decode(Int.self, forKey: .id)
       nomJeu = try container.decode(String.self, forKey: .nomJeu)
       prixUnit = try container.decode(Double.self, forKey: .prixUnit)
       photoPath = try container.decode(String.self, forKey: .photoPath)
       editeur = try container.decodeIfPresent(String.self, forKey: .editeur)
       description = try container.decodeIfPresent(String.self, forKey: .description)
       fraisDepotFixe = try container.decode(Int.self, forKey: .fraisDepotFixe)
       fraisDepotPercent = try container.decode(Int.self, forKey: .fraisDepotPercent)
       prixFinal = try container.decode(Double.self, forKey: .prixFinal)
       let estEnVenteInt = try container.decode(Int.self, forKey: .estEnVente)
       estEnVente = (estEnVenteInt == 1)
    }
    
    /// Initialisation manuelle pour les tests ou mocks
    init(id: Int, nomJeu: String, prixUnit: Double, photoPath: String, 
         editeur: String? = nil, description: String? = nil,
         fraisDepotFixe: Int, fraisDepotPercent: Int, 
         prixFinal: Double, estEnVente: Bool) {
        self.id = id
        self.nomJeu = nomJeu
        self.prixUnit = prixUnit
        self.photoPath = photoPath
        self.editeur = editeur
        self.description = description
        self.fraisDepotFixe = fraisDepotFixe
        self.fraisDepotPercent = fraisDepotPercent
        self.prixFinal = prixFinal
        self.estEnVente = estEnVente
    }
}