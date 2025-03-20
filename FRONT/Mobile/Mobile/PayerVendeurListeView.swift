import SwiftUI

struct PayerVendeurListeView: View {
    let email: String
    let onRetour: () -> Void

    @State private var historiqueVentes: [Vente] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 30)

                        // Bouton retour + Titre
                        HStack {
                            Button(action: onRetour) {
                                Image("retour")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                            }
                            .padding(.leading, 20)

                            Spacer()

                            Text("Historique des ventes")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.trailing, 50)

                            Spacer()
                        }
                        .padding(.top, 10)

                        // Tableau de ventes
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                cellHeader("Nom du Jeu", geometry: geometry)
                                cellHeader("Qté vendue", geometry: geometry)
                                cellHeader("Prix vendeur", geometry: geometry)
                                cellHeader("Payé", geometry: geometry)
                            }
                            .frame(height: 40)
                            .background(Color.gray.opacity(0.2))

                            ForEach(historiqueVentes) { vente in
                                HStack(spacing: 0) {
                                    cellBody(vente.nomJeu, geometry: geometry)
                                    cellBody("\(vente.quantiteVendue)", geometry: geometry)
                                    cellBody(String(format: "%.2f€", vente.prixUnit), geometry: geometry)
                                    cellBody(vente.vendeurPaye ? "Oui" : "Non", geometry: geometry)
                                }
                            }
                        }
                        .border(Color.black)
                        .frame(width: geometry.size.width * 0.9)
                        .padding(.horizontal, geometry.size.width * 0.05)

                        // Somme totale
                        Text("Somme totale : \(historiqueVentes.first?.sommeTotaleDue ?? 0, specifier: "%.2f") €")
                            .font(.system(size: 18, weight: .bold))
                            .padding()

                        // Bouton pour payer le vendeur
                        Button(action: payerVendeur) {
                            Text("Payer le vendeur")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.system(size: 17, weight: .bold))
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)

                        Spacer(minLength: 50)
                    }
                }
            }
            .onAppear(perform: fetchHistorique)
        }
    }

    private func fetchHistorique() {
        // Exemple factice : remplacer par l'appel HTTP réel
        self.historiqueVentes = [
            Vente(id: 1, nomJeu: "Monopoly", quantiteVendue: 3, prixUnit: 15.0, vendeurPaye: false, sommeTotaleDue: 45),
            Vente(id: 2, nomJeu: "Catan", quantiteVendue: 2, prixUnit: 20.0, vendeurPaye: true, sommeTotaleDue: 40)
        ]
    }

    private func payerVendeur() {
        print("Vendeur payé")              // logique existante (ex: appel HTTP réel)
        scheduleNotification()             // appel de la notification
    }

    // Définition de la fonction juste en dessous :
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Paiement effectué"
        content.body = "Le vendeur a été payé avec succès."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func largeurColonne(_ geometry: GeometryProxy) -> CGFloat {
        (geometry.size.width * 0.9) / 4
    }

    private func cellHeader(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(width: largeurColonne(geometry), height: 40)
            .border(Color.black)
    }

    private func cellBody(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 13))
            .multilineTextAlignment(.center)
            .frame(width: largeurColonne(geometry), height: 40)
            .border(Color.black)
    }
}

struct Vente: Identifiable {
    let id: Int
    let nomJeu: String
    let quantiteVendue: Int
    let prixUnit: Double
    let vendeurPaye: Bool
    let sommeTotaleDue: Double
}
