import Foundation

struct BilanData {
    let bilanParticulier: Bool
    
    let sessionParticuliere: Bool
    
    let emailParticulier: String
    
    let numeroSession: String
    
    let chargesFixes: Double
}

/// data pour le graphique de bénéfices
struct ProfitDataPoint: Identifiable {
    var id = UUID()
    let salesQuantity: Int
    let profit: Double
}

/// data graphique circulaire
struct PieChartData: Identifiable {
    var id = UUID()
    let name: String
    let value: Double
    let color: String
}