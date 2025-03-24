import Foundation
import SwiftUI

class VendeurGrapheViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    
    @Published var profitDataPoints: [ProfitDataPoint] = []
    
    @Published var pieChartData: [PieChartData] = []
    
    @Published var stockTurnoverRate: Int = 0
    
    // MARK: - Propriétés privées
    
    private let bilanData: BilanData
    
    // MARK: - Initialisation
    
    init(bilanData: BilanData) {
        self.bilanData = bilanData
        
        setupProfitData()
        setupPieChartData()
    }
    
    // MARK: - Propriétés calculées
    
    var chargesFixes: Double {
        bilanData.chargesFixes
    }
    
    var titleText: String {
        if bilanData.bilanParticulier && !bilanData.emailParticulier.isEmpty {
            return "BILAN VENDEUR - \(bilanData.emailParticulier)"
        }
        return "BILAN VENDEUR"
    }
    
    var subtitleText: String {
        if bilanData.sessionParticuliere && !bilanData.numeroSession.isEmpty {
            return "Session \(bilanData.numeroSession) - Bénéfices"
        }
        return "Les bénéfices engendrés"
    }
    
    // MARK: - Méthodes privées
    
    private func setupProfitData() {
        let salesQuantities = [10, 100, 150, 200, 250, 300]
        let profits = [3, 50, 100, 150, 200, 250]
        
        for i in 0..<min(salesQuantities.count, profits.count) {
            profitDataPoints.append(
                ProfitDataPoint(salesQuantity: salesQuantities[i], profit: profits[i])
            )
        }
    }
    
    private func setupPieChartData() {
        stockTurnoverRate = 70
        
        pieChartData = [
            PieChartData(name: "Vendu", value: Double(stockTurnoverRate), color: "blue"),
            PieChartData(name: "Non vendu", value: Double(100 - stockTurnoverRate), color: "red")
        ]
    }
    
    // MARK: - Méthodes publiques
    
    func colorForPieSegment(_ segment: PieChartData) -> Color {
        switch segment.color {
        case "blue":
            return .blue
        case "red":
            return .red.opacity(0.6)
        default:
            return .gray
        }
    }
}