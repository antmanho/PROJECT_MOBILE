
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
    @State private var errorMessage: String = ""
    
    let baseURL = BaseUrl.lien
    
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
                        
                        // Message d'erreur inline en rouge
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
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
                        
                        Button(action: {
                            errorMessage = ""
                            payerVendeur()
                        }) {
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
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear(perform: fetchHistorique)
    }
    
    private func fetchHistorique() {
        guard let url = URL(string: "\(baseURL)/historique-vente/\(email)") else {
            errorMessage = "URL invalide pour historique"
            scheduleNotification(title: "Erreur", message: errorMessage)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Aucune donnée reçue"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            do {
                let decodedVentes = try JSONDecoder().decode([Vente].self, from: data)
                DispatchQueue.main.async {
                    self.historiqueVentes = decodedVentes
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Erreur de décodage: \(error)"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
            }
        }.resume()
    }
    
    private func payerVendeur() {
        guard let url = URL(string: "\(baseURL)/payer-vendeur-liste") else {
            errorMessage = "URL invalide pour payer le vendeur"
            scheduleNotification(title: "Erreur", message: errorMessage)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors du paiement: \(error.localizedDescription)"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            if let data = data,
               let _ = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    scheduleNotification(title: "Succès", message: "Le vendeur a été payé avec succès.")
                    fetchHistorique()
                }
            }
        }.resume()
    }
    
    private func scheduleNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
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

struct PayerVendeurListeView_Previews: PreviewProvider {
    static var previews: some View {
        PayerVendeurListeView(email: "vendeur@example.com", onRetour: { })
    }
}
