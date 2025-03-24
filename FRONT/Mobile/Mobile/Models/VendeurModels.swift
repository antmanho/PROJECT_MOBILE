import Foundation

struct SoldGame: Identifiable, Decodable {
    let id = UUID() 
    let nomJeu: String      
    let prixUnit: Double   
    let photoPath: String   
    let quantiteVendue: Int 

    private enum CodingKeys: String, CodingKey {
        case nomJeu = "nom_jeu", prixUnit = "Prix_unit", photoPath = "photo_path", quantiteVendue = "Quantite_vendu"
    }
    
    var prixFormatte: String {
        String(format: "%.2f €", prixUnit)
    }
    
    func getFullImageUrl(baseUrl: String) -> URL? {
        return URL(string: baseUrl + photoPath)
    }
}

struct CatalogueResponse2: Decodable {
    let results: [Game]
    let email_connecte: String
}