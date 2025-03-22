import SwiftUI
import UserNotifications

struct EnregistrerAchatView: View {
    @State private var idStock: String = ""
    @State private var quantiteVendue: String = ""
    let onConfirmerAchat: (String, String) -> Void
    
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
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
                            
                            TextField("ID Stock", text: $idStock)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            TextField("Quantité Vendue", text: $quantiteVendue)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.numberPad)
                            
                            Button {
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func confirmerAchat() {
        guard let url = URL(string: "http://localhost:3000/enregistrer-achat") else {
            alertMessage = "URL invalide"
            showAlert = true
            return
        }
        
        // Préparer le corps de la requête
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
                    alertMessage = "Erreur: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            guard let data = data,
                  let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = responseJSON["message"] as? String else {
                DispatchQueue.main.async {
                    alertMessage = "Réponse invalide du serveur"
                    showAlert = true
                }
                return
            }
            DispatchQueue.main.async {
                alertMessage = message
                showAlert = true
                scheduleNotification()
            }
        }.resume()
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Achat enregistré"
        content.body = "Votre achat a été enregistré avec succès."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur notification: \(error.localizedDescription)")
            }
        }
    }
}

struct EnregistrerAchatView_Previews: PreviewProvider {
    static var previews: some View {
        EnregistrerAchatView(onConfirmerAchat: { id, quantite in
            print("Achat confirmé : ID Stock \(id), Quantité \(quantite)")
        })
    }
}

