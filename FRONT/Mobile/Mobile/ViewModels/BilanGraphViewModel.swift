import Foundation
import SwiftUI
import Combine
import BilanGraphData

class BilanGraphViewModel: ObservableObject {
    // Input data
    private let graphData: BilanGraphData
    
    // Output properties for the view
    @Published var chartData: BilanGraphData
    
    // Computed properties
    var tauxRotation: String {
        guard chartData.totalQuantiteDeposee > 0 else { return "N/A" }
        let taux = (Double(chartData.totalQuantiteVendu) / chartData.totalQuantiteDeposee) * 100
        return String(format: "%.0f%%", taux)
    }
    
    var totalVendu: Int {
        return chartData.totalQuantiteVendu
    }
    
    var totalNonVendu: Int {
        return max(0, Int(chartData.totalQuantiteDeposee) - chartData.totalQuantiteVendu)
    }
    
    init(data: BilanGraphData) {
        self.graphData = data
        self.chartData = data
    }
}