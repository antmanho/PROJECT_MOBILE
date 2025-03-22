import SwiftUI
import Charts

struct BilanGrapheView: View {
    @ObservedObject var viewModel: BilanGraphViewModel
    let onRetour: () -> Void

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                // Bouton retour
                HStack {
                    Button(action: onRetour) {
                        Image("retour")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 15)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                
                Text("BILAN FINANCIER")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top, 5)
                
                // Graphique linéaire basé sur les données retournées par le back
                Chart {
                    ForEach(viewModel.chartData.listeX.indices, id: \.self) { index in
                        if index < viewModel.chartData.listeYSomme.count {
                            LineMark(
                                x: .value("Index", viewModel.chartData.listeX[index]),
                                y: .value("Prix cumulé", viewModel.chartData.listeYSomme[index])
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                        }
                    }
                    // Règle pour afficher les charges fixes
                    RuleMark(y: .value("Charges fixes", viewModel.chartData.chargesFixes))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundStyle(.yellow)
                        .annotation(position: .top, alignment: .leading) {
                            Text("Charges fixes")
                                .foregroundColor(.yellow)
                        }
                }
                .frame(height: 160)
                .padding(.horizontal)
                .chartXAxisLabel("Nombre de ventes")
                .chartYAxisLabel("Euros (€)")
                
                Text("Quand la courbe est au-dessus de la ligne jaune, vous êtes bénéficiaire.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Graphique en camembert
                Text("Quantité Vendue")
                    .font(.headline)
                
                HStack {
                    Chart {
                        SectorMark(angle: .value("Vendu", viewModel.totalVendu))
                            .foregroundStyle(.blue)
                        SectorMark(angle: .value("Non vendu", viewModel.totalNonVendu))
                            .foregroundStyle(.red.opacity(0.6))
                    }
                    .frame(width: 130, height: 130)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Vendu (\(viewModel.totalVendu))", systemImage: "circle.fill")
                            .foregroundColor(.blue)
                        Label("Non vendu (\(viewModel.totalNonVendu))", systemImage: "circle.fill")
                            .foregroundColor(.red.opacity(0.6))
                    }
                }
                
                // Affichage du taux de rotation
                Text("Taux de rotation des stocks : \(viewModel.tauxRotation)")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
                
                Spacer()
                
                Text("Bilan financier réalisé par l'équipe BoardLand")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 25)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                viewModel.loadBilanData()
            }
        }
    }
}

struct BilanGrapheView_Previews: PreviewProvider {
    static var previews: some View {
        let data = BilanGraphData(
            listeYSomme: [10, 20, 30],
            listeY2Somme: [5, 10, 15],
            listeY3Somme: [3, 6, 9],
            listeX: [1, 2, 3],
            totalQuantiteDeposee: 100,
            totalQuantiteVendu: 50,
            chargesFixes: 25.0
        )
        let viewModel = BilanGraphViewModel(data: data)
        return BilanGrapheView(viewModel: viewModel, onRetour: { })
    }
}