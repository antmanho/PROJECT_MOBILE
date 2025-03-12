// BilanGrapheView.swift

import SwiftUI
import Charts // For iOS 16+
import Combine

struct BilanGrapheView: View {
    var bilanData: BilanData?
    var bilanParticulier: Bool
    var sessionParticuliere: Bool
    var emailParticulier: String
    var numeroSession: String
    var chargesFixes: Double
    
    @StateObject private var bilanService = BilanService()
    @State private var lineChartData: [ChartDataEntry] = []
    @State private var pieChartData: [PieChartDataEntry] = []
    @State private var ratioDisplay: String = ""
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("BILAN FINANCIER")
                    .font(.title)
                    .fontWeight(.bold)
                
                if isLoading {
                    ProgressView("Chargement des données...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Linear Chart Section
                    VStack(alignment: .center, spacing: 10) {
                        Text("Les bénéfices engendrées")
                            .font(.headline)
                        
                        // iOS 16+ Chart
                        if #available(iOS 16.0, *) {
                            Chart {
                                ForEach(lineChartData.indices, id: \.self) { index in
                                    let entry = lineChartData[index]
                                    LineMark(
                                        x: .value("Date", entry.label),
                                        y: .value("Bénéfice", entry.value)
                                    )
                                    .foregroundStyle(.blue)
                                }
                                
                                // Reference line (the yellow line)
                                RuleMark(y: .value("Seuil de rentabilité", 0))
                                    .foregroundStyle(.yellow)
                            }
                            .frame(height: 300)
                            .padding()
                        } else {
                            // Fallback for iOS versions before 16
                            Text("Graphique disponible sur iOS 16+")
                                .italic()
                        }
                        
                        Text("Quand la courbe de bénéfice se trouve en haut de la droite jaune, vous êtes bénéficiaire.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    // Pie Chart Section
                    VStack(alignment: .center, spacing: 10) {
                        Text("La quantité vendue")
                            .font(.headline)
                        
                        // iOS 16+ Chart
                        if #available(iOS 16.0, *) {
                            Chart {
                                ForEach(pieChartData.indices, id: \.self) { index in
                                    let entry = pieChartData[index]
                                    SectorMark(
                                        angle: .value("Value", entry.value),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1
                                    )
                                    .foregroundStyle(by: .value("Category", entry.label))
                                }
                            }
                            .frame(height: 300)
                            .padding()
                        } else {
                            // Fallback for iOS versions before 16
                            Text("Graphique disponible sur iOS 16+")
                                .italic()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    
                    // Ratio Display
                    VStack(alignment: .center, spacing: 5) {
                        Text("TAUX DE ROTATION DES STOCKS :")
                            .font(.headline)
                        Text(ratioDisplay)
                            .font(.title2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                }
                
                // Back button
                Button(action: {
                    // Navigate back to form
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Retour")
                    }
                }
                .padding()
            }
            .padding()
        }
        .onAppear {
            if let data = bilanData {
                processData(data)
            } else {
                loadBilanData()
            }
        }
    }
    
    private func loadBilanData() {
        bilanService.fetchBilanData(
            bilanParticulier: bilanParticulier,
            sessionParticuliere: sessionParticuliere,
            emailParticulier: emailParticulier,
            numeroSession: numeroSession,
            chargesFixes: chargesFixes
        )
        .sink(
            receiveCompletion: { completion in
                isLoading = false
                if case let .failure(error) = completion {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                }
            },
            receiveValue: { data in
                if let message = data.message {
                    errorMessage = message
                } else {
                    processData(data)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    private func processData(_ data: BilanData) {
        // Process line chart data
        if let listeX = data.listeX, let listeYSomme = data.listeYSomme {
            lineChartData = zip(listeX, listeYSomme).map { (label, value) in
                ChartDataEntry(label: label, value: value)
            }
        }
        
        // Process pie chart data
        if let totalDepose = data.totalQuantiteDeposee, let totalVendu = data.totalQuantiteVendu {
            let nonVendu = totalDepose - totalVendu
            pieChartData = [
                PieChartDataEntry(label: "Vendus", value: Double(totalVendu)),
                PieChartDataEntry(label: "Non vendus", value: Double(nonVendu))
            ]
            
            // Calculate ratio
            calculateRatio(totalDepose: totalDepose, totalVendu: totalVendu)
        }
        
        isLoading = false
    }
    
    private func calculateRatio(totalDepose: Int, totalVendu: Int) {
        let ratio = Double(totalVendu) / Double(totalDepose)
        let percentage = ratio * 100
        ratioDisplay = String(format: "%.2f%%", percentage)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// Data structures for charts
struct ChartDataEntry {
    let label: String
    let value: Double
}

struct PieChartDataEntry {
    let label: String
    let value: Double
}

struct BilanGrapheView_Previews: PreviewProvider {
    static var previews: some View {
        BilanGrapheView(
            bilanParticulier: false,
            sessionParticuliere: false,
            emailParticulier: "",
            numeroSession: "",
            chargesFixes: 0
        )
    }
}