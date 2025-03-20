import SwiftUI
import Charts

struct BilanGrapheView: View {
    let data: BilanData
    let onRetour: () -> Void

    let ventes = [10,100, 150, 200, 250, 300]
    let benefices = [3,50, 100, 150, 200, 250]

    var body: some View {
        GeometryReader { geometry in
            ZStack {

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
                    }.padding(.top, 10)

                    Text("BILAN FINANCIER")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.top, 5)

                    // Graphique linéaire
                    Text("Les bénéfices engendrés")
                        .font(.headline)

                    Chart {
                        ForEach(ventes.indices, id: \..self) { index in
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

                    Text("Bilan financier réalisé par l'équipe BoardLand")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 25)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
