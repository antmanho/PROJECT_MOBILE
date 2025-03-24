import SwiftUI
import Charts

struct VendeurGrapheView: View {
    let data: BilanData
    
    let onRetour: () -> Void
    
    @StateObject private var viewModel: VendeurGrapheViewModel
    
    init(data: BilanData, onRetour: @escaping () -> Void) {
        self.data = data
        self.onRetour = onRetour
        self._viewModel = StateObject(wrappedValue: VendeurGrapheViewModel(bilanData: data))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(spacing: 12) {
                        headerView
                        
                        profitChartSection
                        
                        Divider().padding(.horizontal)
                        
                        pieChartSection
                        
                        footerView
                    }
                    .frame(width: geometry.size.width)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    // MARK: - Sous-vues
    
    private var headerView: some View {
        VStack {
            HStack {
                Button(action: onRetour) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(.leading, 15)
                }
                Spacer()
            }.padding(.top, 10)
            
            Text(viewModel.titleText)
                .font(.system(size: 22, weight: .bold))
                .padding(.top, 5)
            
            Text(viewModel.subtitleText)
                .font(.headline)
        }
    }
    
    // Section du graphique linéaire des bénéfices
    private var profitChartSection: some View {
        VStack {
            Chart {
                ForEach(viewModel.profitDataPoints) { dataPoint in
                    LineMark(
                        x: .value("Quantité vendue", dataPoint.salesQuantity),
                        y: .value("Bénéfices (€)", dataPoint.profit)
                    )
                    .foregroundStyle(.blue)
                    .symbol(Circle())
                }
                
                RuleMark(y: .value("Charges fixes", viewModel.chargesFixes))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.yellow)
                    .annotation(position: .top, alignment: .leading) {
                        Text("Charges fixes").foregroundColor(.yellow)
                    }
            }
            .frame(height: 160)
            .padding(.horizontal)
            .chartXAxisLabel("Nombre de ventes")
            .chartYAxisLabel("Euros (€)")
            
            Text("Au-dessus de la ligne jaune, vous êtes bénéficiaire.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // Section du graphique circulaire des ventes
    private var pieChartSection: some View {
        VStack {
            Text("Quantité Vendue")
                .font(.headline)
            
            HStack {
                Chart {
                    ForEach(viewModel.pieChartData) { dataPoint in
                        SectorMark(
                            angle: .value(dataPoint.name, dataPoint.value)
                        )
                        .foregroundStyle(viewModel.colorForPieSegment(dataPoint))
                    }
                }
                .frame(width: 130, height: 130)
                
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.pieChartData) { dataPoint in
                        Label(
                            "\(dataPoint.name) (\(Int(dataPoint.value))%)",
                            systemImage: "circle.fill"
                        )
                        .foregroundColor(viewModel.colorForPieSegment(dataPoint))
                    }
                }
            }
            
            Text("Taux de rotation des stocks : \(viewModel.stockTurnoverRate)%")
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 3)
        }
    }
    
    private var footerView: some View {
        VStack {
            Spacer(minLength: 10)
            
            Text("Bilan vendeur réalisé par l'équipe BoardLand")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 25)
        }
    }
}

/// Prévisualisation pour Xcode
struct VendeurGrapheView_Previews: PreviewProvider {
    static var previews: some View {
        VendeurGrapheView(
            data: BilanData(
                bilanParticulier: false,
                sessionParticuliere: false,
                emailParticulier: "",
                numeroSession: "",
                chargesFixes: 100
            ),
            onRetour: {}
        )
    }
}