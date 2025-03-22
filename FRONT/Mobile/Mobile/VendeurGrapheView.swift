import SwiftUI
import Charts
import Foundation

struct BilanData {
    let bilanParticulier: Bool
    let sessionParticuliere: Bool
    let emailParticulier: String
    let numeroSession: String
    let chargesFixes: Double
}

struct VendeurGrapheView: View {
    let data: BilanData
    let onRetour: () -> Void

    let ventes = [10, 100, 150, 200, 250, 300]
    let benefices = [3, 50, 100, 150, 200, 250]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 12) {
                    HStack {
                        Button(action: onRetour) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.leading, 15)
                        }
                        Spacer()
                    }.padding(.top, 10)

                    Text("BILAN VENDEUR")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.top, 5)

                    Text("Les bénéfices engendrés")
                        .font(.headline)

                    Chart {
                        ForEach(ventes.indices, id: \.self) { index in
                            LineMark(
                                x: .value("Quantité vendue", ventes[index]),
                                y: .value("Bénéfices (€)", benefices[index])
                            )
                            .foregroundStyle(.blue)
                            .symbol(Circle())
                        }

                        RuleMark(y: .value("Charges fixes", data.chargesFixes))
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

                    Divider().padding(.horizontal)

                    Text("Quantité Vendue")
                        .font(.headline)

                    HStack {
                        Chart {
                            SectorMark(angle: .value("Vendu", 70)).foregroundStyle(.blue)
                            SectorMark(angle: .value("Non vendu", 30)).foregroundStyle(.red.opacity(0.6))
                        }
                        .frame(width: 130, height: 130)

                        VStack(alignment: .leading, spacing: 10) {
                            Label("Vendu (70%)", systemImage: "circle.fill")
                                .foregroundColor(.blue)
                            Label("Non vendu (30%)", systemImage: "circle.fill")
                                .foregroundColor(.red.opacity(0.6))
                        }
                    }

                    Text("Taux de rotation des stocks : 70%")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)

                    Spacer(minLength: 10)

                    Text("Bilan vendeur réalisé par l'équipe BoardLand")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 25)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

struct VendeurGrapheView_Previews: PreviewProvider {
    static var previews: some View {
        VendeurGrapheView(
            data: BilanData(bilanParticulier: false, sessionParticuliere: false, emailParticulier: "", numeroSession: "", chargesFixes: 100),
            onRetour: {}
        )
    }
}
