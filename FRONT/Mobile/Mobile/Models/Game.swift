import Foundation

struct Game: Identifiable, Decodable {
    let id: Int               // Correspond à id_stock
    let nomJeu: String        // Correspond à nom_jeu
    let prixUnit: Double      // Correspond à Prix_unit
    let photoPath: String?    // Correspond à photo_path (maintenant optionnel)
    let fraisDepotFixe: Int   // Correspond à Frais_depot_fixe
    let fraisDepotPercent: Int// Correspond à Frais_depot_percent
    let prixFinal: Double     // Correspond à prix_final
    var estEnVente: Bool      // Converti depuis un entier (1 ou 0)
    
    // Ajouté pour corriger l'erreur estEpuise
    var quantiteDisponible: Int = 1
    
    private enum CodingKeys: String, CodingKey {
        case id = "id_stock"
        case nomJeu = "nom_jeu"
        case prixUnit = "Prix_unit"
        case photoPath = "photo_path"
        case fraisDepotFixe = "Frais_depot_fixe"
        case fraisDepotPercent = "Frais_depot_percent"
        case prixFinal = "prix_final"
        case estEnVente = "est_en_vente"
        case quantiteDisponible = "quantite_dispo" // Ajouté cette clé
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.nomJeu = try container.decode(String.self, forKey: .nomJeu)
        self.prixUnit = try container.decode(Double.self, forKey: .prixUnit)
        self.photoPath = try container.decodeIfPresent(String.self, forKey: .photoPath)
        self.fraisDepotFixe = try container.decode(Int.self, forKey: .fraisDepotFixe)
        self.fraisDepotPercent = try container.decode(Int.self, forKey: .fraisDepotPercent)
        self.prixFinal = try container.decode(Double.self, forKey: .prixFinal)
        let estEnVenteValue = try container.decode(Int.self, forKey: .estEnVente)
        self.estEnVente = (estEnVenteValue == 1)
        
        // Décodage de la quantité disponible (avec valeur par défaut)
        self.quantiteDisponible = try container.decodeIfPresent(Int.self, forKey: .quantiteDisponible) ?? 1
    }
    
    init(id: Int, nomJeu: String, prixUnit: Double, photoPath: String?, fraisDepotFixe: Int, fraisDepotPercent: Int, prixFinal: Double, estEnVente: Bool, quantiteDisponible: Int = 1) {
        self.id = id
        self.nomJeu = nomJeu
        self.prixUnit = prixUnit
        self.photoPath = photoPath
        self.fraisDepotFixe = fraisDepotFixe
        self.fraisDepotPercent = fraisDepotPercent
        self.prixFinal = prixFinal
        self.estEnVente = estEnVente
        self.quantiteDisponible = quantiteDisponible
    }

    /// URL complète de l'image
    func getFullImageUrl(baseUrl: String) -> URL? {
        guard let photoPath = photoPath else { return nil }
        return URL(string: baseUrl + photoPath)
    }
    
    /// Prix formaté avec symbole €
    var prixFormatte: String {
        String(format: "%.2f €", prixUnit)
    }
    
    /// Indique si le jeu est épuisé
    var estEpuise: Bool {
        quantiteDisponible <= 0
    }
    
    /// Indique si le jeu est accessible à un rôle spécifique
    func isAccessibleTo(role: UserRole) -> Bool {
        if !estEnVente { 
            return role == .admin || role == .gestionnaire
        }
        return true
    }
}

struct CatalogueResponse: Decodable {
    let results: [Game]
}