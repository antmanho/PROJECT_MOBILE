
import SwiftUI
import UserNotifications

// Modèle de vente adapté au JSON renvoyé par votre backend.
struct Vente: Identifiable, Decodable {
    let id: UUID
    let nomJeu: String
    let quantiteVendue: Int
    let prixUnit: Double
    let vendeurPaye: Bool
    let sommeTotaleDue: Double

    enum CodingKeys: String, CodingKey {
        case nomJeu = "nom_jeu"
        case quantiteVendue = "Quantite_vendu"
        case prixUnit = "Prix_unit"
        case vendeurPaye = "vendeur_paye"
        case sommeTotaleDue = "Somme_total_du"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nomJeu = try container.decode(String.self, forKey: .nomJeu)
        self.quantiteVendue = try container.decode(Int.self, forKey: .quantiteVendue)
        self.prixUnit = try container.decode(Double.self, forKey: .prixUnit)
        // Décoder comme Int et convertir en Bool
        let vendeurPayeInt = try container.decode(Int.self, forKey: .vendeurPaye)
        self.vendeurPaye = (vendeurPayeInt == 1)
        self.sommeTotaleDue = try container.decode(Double.self, forKey: .sommeTotaleDue)
        self.id = UUID() // Génère un identifiant unique pour chaque instance
    }
}



struct PayerVendeurListeView: View {
    let email: String
    let onRetour: () -> Void

    @State private var historiqueVentes: [Vente] = []

    // Base URL à adapter si nécessaire
    let baseURL = "http://localhost:3000"

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 30)

                        // Bouton retour et titre
                        HStack {
                            Button(action: onRetour) {
                                Image("retour")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(.leading, 20)
                            }
                            Spacer()
                            Text("Historique des ventes")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.trailing, 50)
                            Spacer()
                        }
                        .padding(.top, 10)

                        // Tableau des ventes
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
                        Text("Somme totale : \(String(format: "%.2f", historiqueVentes.first?.sommeTotaleDue ?? 0)) €")
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
        guard let url = URL(string: "\(baseURL)/historique-vente/\(email)") else {
            print("URL invalide pour historique")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors du chargement de l'historique: \(error)")
                return
            }
            guard let data = data else {
                print("Aucune donnée reçue")
                return
            }
            do {
                let decodedVentes = try JSONDecoder().decode([Vente].self, from: data)
                DispatchQueue.main.async {
                    self.historiqueVentes = decodedVentes
                }
            } catch {
                print("Erreur de décodage de l'historique: \(error)")
            }
        }.resume()
    }

    private func payerVendeur() {
        // Préparer l'URL et le corps de la requête pour /payer-vendeur-liste
        guard let url = URL(string: "\(baseURL)/payer-vendeur-liste") else {
            print("URL invalide pour payer le vendeur")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors du paiement du vendeur: \(error)")
                return
            }
            if let data = data,
               let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Réponse du paiement vendeur: \(responseJSON)")
                // Une fois que le vendeur est payé, vous pouvez rafraîchir l'historique
                fetchHistorique()
                scheduleNotification()
            }
        }.resume()
    }

    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Paiement effectué"
        content.body = "Le vendeur a été payé avec succès."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de la notification: \(error.localizedDescription)")
            }
        }
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

struct PayerVendeurListeView_Previews: PreviewProvider {
    static var previews: some View {
        PayerVendeurListeView(email: "vendeur@example.com", onRetour: { })
    }
}

