import SwiftUI
import UserNotifications

// Modèle de données pour un jeu
struct Jeu: Identifiable, Decodable {
    let id_stock: Int
    let nom_jeu: String
    let prix_unit: Double
    let quantiteActuelle: Int
    var selectionne: Bool = false

    var id: Int { id_stock }

    enum CodingKeys: String, CodingKey {
        case id_stock
        case nom_jeu
        case prix_unit = "Prix_unit"           // Assurez-vous que c'est exactement la clé renvoyée
        case quantiteActuelle = "Quantite_actuelle"
    }
}


struct RetraitListeView: View {
    let email: String
    let onRetour: () -> Void   // Retour vers la vue précédente
    let onInvité: () -> Void   // Par exemple, pour retourner en mode invité

    @State private var jeux: [Jeu] = []
    
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
                                    .padding()
                            }
                            Spacer()
                            Text("Retirer jeu")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.trailing, 50)
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        // Tableau listant les jeux
                        VStack(spacing: 0) {
                            // Ligne d'entête
                            HStack(spacing: 0) {
                                cellHeader("ID Stock", geometry: geometry)
                                cellHeader("Nom du Jeu", geometry: geometry)
                                cellHeader("Prix Demandé", geometry: geometry)
                                cellHeader("Sélection", geometry: geometry)
                            }
                            .frame(height: 40)
                            .background(Color.gray.opacity(0.2))
                            
                            // Lignes pour chaque jeu
                            ForEach(jeux.indices, id: \.self) { index in
                                HStack(spacing: 0) {
                                    cellBody("\(jeux[index].id_stock)", geometry: geometry)
                                    cellBody(jeux[index].nom_jeu, geometry: geometry)
                                    cellBody(String(format: "%.2f€", jeux[index].prix_unit), geometry: geometry)
                                    Toggle("", isOn: $jeux[index].selectionne)
                                        .labelsHidden()
                                        .frame(width: largeurColonne(geometry), height: 40)
                                        .border(Color.black)
                                }
                            }

                        }
                        .border(Color.black)
                        .frame(width: geometry.size.width * 0.9)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        
                        // Bouton pour retirer les jeux sélectionnés
                        Button(action: retirerJeux) {
                            Text("Retirer les jeux sélectionnés")
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
            .onAppear(perform: fetchJeux)
        }
    }
    
    // Fonction pour récupérer les jeux du vendeur depuis le backend
    private func fetchJeux() {
        guard let url = URL(string: "http://localhost:3000/retrait-liste/\(email)") else {
            print("URL invalide")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors du chargement des jeux: \(error)")
                return
            }
            guard let data = data else {
                print("Aucune donnée reçue")
                return
            }
            do {
                let decodedJeux = try JSONDecoder().decode([Jeu].self, from: data)
                DispatchQueue.main.async {
                    self.jeux = decodedJeux
                }
            } catch {
                print("Erreur de décodage: \(error)")
            }
        }.resume()
    }
    
    // Fonction qui envoie une requête pour retirer chaque jeu sélectionné
    private func retirerJeux() {
        // Pour chaque jeu sélectionné, envoyer une requête POST vers /retrait
        for jeu in jeux where jeu.selectionne {
            retirerJeu(jeu: jeu)
        }
        // Rafraîchir la liste après les suppressions
        fetchJeux()
        scheduleNotification()
    }
    
    // Envoi d'une requête POST pour retirer un jeu
    private func retirerJeu(jeu: Jeu) {
        guard let url = URL(string: "http://localhost:3000/retrait") else {
            print("URL invalide pour retrait")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Ici, le nombre de checkbox sélectionné est fixé à 1, car chaque jeu représente une unité (duplication effectuée côté back)
        let body: [String: Any] = [
            "id_stock": jeu.id_stock,
            "nombre_checkbox_selectionne_cet_id": 1
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors du retrait du jeu \(jeu.id_stock): \(error)")
                return
            }
            if let data = data,
               let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("Réponse retrait pour jeu \(jeu.id_stock): \(responseJSON)")
            }
        }.resume()
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Retrait effectué"
        content.body = "Les jeux sélectionnés ont été retirés avec succès."
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

struct RetraitListeView_Previews: PreviewProvider {
    static var previews: some View {
        RetraitListeView(email: "test@example.com", onRetour: { }, onInvité: { })
    }
}
