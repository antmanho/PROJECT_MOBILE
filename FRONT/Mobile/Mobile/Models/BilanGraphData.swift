import Foundation

struct BilanGraphData: Decodable {
    let listeYSomme: [Double]
    let listeY2Somme: [Double]
    let listeY3Somme: [Double]
    let listeX: [Int]
    let totalQuantiteDeposee: Double
    let totalQuantiteVendu: Int
    let chargesFixes: Double

    enum CodingKeys: String, CodingKey {
        case listeYSomme, listeY2Somme, listeY3Somme, listeX, totalQuantiteDeposee, totalQuantiteVendu, chargesFixes
    }

    // Initialiseur personnalisé pour le décodage
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.listeYSomme = try container.decode([Double].self, forKey: .listeYSomme)
        self.listeY2Somme = try container.decode([Double].self, forKey: .listeY2Somme)
        self.listeY3Somme = try container.decode([Double].self, forKey: .listeY3Somme)
        self.listeX = try container.decode([Int].self, forKey: .listeX)
        self.totalQuantiteDeposee = try container.decode(Double.self, forKey: .totalQuantiteDeposee)
        self.totalQuantiteVendu = try container.decode(Int.self, forKey: .totalQuantiteVendu)
        
        if let charges = try? container.decode(Double.self, forKey: .chargesFixes) {
            self.chargesFixes = charges
        } else {
            let chargesString = try container.decode(String.self, forKey: .chargesFixes)
            self.chargesFixes = Double(chargesString) ?? 0.0
        }
    }
    
    // Initialiseur membre explicite
    init(listeYSomme: [Double], listeY2Somme: [Double], listeY3Somme: [Double], listeX: [Int], 
         totalQuantiteDeposee: Double, totalQuantiteVendu: Int, chargesFixes: Double) {
        self.listeYSomme = listeYSomme
        self.listeY2Somme = listeY2Somme
        self.listeY3Somme = listeY3Somme
        self.listeX = listeX
        self.totalQuantiteDeposee = totalQuantiteDeposee
        self.totalQuantiteVendu = totalQuantiteVendu
        self.chargesFixes = chargesFixes
    }
}