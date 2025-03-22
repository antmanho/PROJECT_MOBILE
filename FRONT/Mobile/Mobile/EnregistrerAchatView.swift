import SwiftUI
import UserNotifications

struct EnregistrerAchatView: View {
    @State private var idStock: String = ""
    @State private var quantiteVendue: String = ""
    @State private var errorMessage: String = ""
    let onConfirmerAchat: (String, String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 40)
                        
                        VStack(spacing: 15) {
                            Text("ENREGISTRER UN ACHAT")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Message d'erreur inline en rouge
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            TextField("ID Stock", text: $idStock)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            TextField("Quantité Vendue", text: $quantiteVendue)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            Button {
                                errorMessage = ""
                                // Vérification des champs obligatoires
                                if idStock.trimmingCharacters(in: .whitespaces).isEmpty ||
                                    quantiteVendue.trimmingCharacters(in: .whitespaces).isEmpty {
                                    errorMessage = "Veuillez remplir tous les champs obligatoires."
                                    return
                                }
                                confirmerAchat()
                            } label: {
                                Text("Confirmer l’achat")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.white.opacity(0.97))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }
    
    private func confirmerAchat() {
        guard let url = URL(string: "\(BaseUrl.lien)/enregistrer-achat") else {
            errorMessage = "URL invalide"
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        let body: [String: Any] = [
            "id_stock": idStock,
            "quantite_vendu": quantiteVendue
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                    scheduleLocalNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            guard let data = data,
                  let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = responseJSON["message"] as? String else {
                DispatchQueue.main.async {
                    errorMessage = "Réponse invalide du serveur"
                    scheduleLocalNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            DispatchQueue.main.async {
                scheduleLocalNotification(title: "Succès", message: message)
                // Réinitialiser les champs du formulaire
                idStock = ""
                quantiteVendue = ""
            }
        }.resume()
    }
    
    private func scheduleLocalNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
