import SwiftUI
import UserNotifications

struct MotPasseOublieView: View {
    @State private var email: String = ""
    let onRetourDynamic: () -> Void // Retour dynamique vers la dernière page
    let onInscription: () -> Void

    var body: some View {
        VStack {
            // Bouton retour en haut à gauche
            HStack {
                Button(action: {
                    onRetourDynamic()
                }) {
                    Image("retour")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(6)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            Spacer(minLength: 20)
            
            // Conteneur commun pour les deux cadres avec largeur fixe
            VStack(spacing: 12) {
                // Premier cadre (Formulaire de récupération)
                VStack(spacing: 8) {
                    Text("RÉCUPÉRATION")
                        .font(.custom("Bangers", size: 26))
                    
                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .padding(.top, 4)
                    
                    Text("Problèmes de connexion ?")
                        .font(.headline)
                    
                    Text("Entrez votre adresse e-mail et nous vous enverrons un lien pour récupérer votre compte.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    TextField("Email", text: $email)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    Button(action: {
                        guard !email.isEmpty else {
                            scheduleNotification(title: "Erreur", message: "Veuillez entrer un email valide.")
                            return
                        }
                        guard let url = URL(string: "\(BaseUrl.lien)/mdp_oublie") else {
                            scheduleNotification(title: "Erreur", message: "URL invalide.")
                            return
                        }
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        let body: [String: Any] = ["email": email]
                        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                        
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                DispatchQueue.main.async {
                                    scheduleNotification(title: "Erreur", message: "Erreur: \(error.localizedDescription)")
                                }
                                return
                            }
                            DispatchQueue.main.async {
                                scheduleNotification(title: "Succès", message: "Un mail de récupération vous a été envoyé.")
                            }
                        }.resume()
                        
                    }) {
                        Text("Récupération mot de passe")
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(5)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity) // Force à occuper toute la largeur du conteneur
                .border(Color.black, width: 1)
                
                // Deuxième cadre (Lien vers Inscription)
                VStack {
                    HStack {
                        Text("Vous n'avez pas de compte ?")
                            .font(.footnote)
                        Button(action: {
                            onInscription()
                        }) {
                            Text("Inscrivez-vous")
                                .foregroundColor(.blue)
                                .font(.footnote)
                        }
                    }
                    .frame(maxWidth: .infinity) // Force à occuper toute la largeur
                    .padding(.vertical, 8)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8) // Largeur commune
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 20)
            
            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 18)
        }
        .alert(isPresented: .constant(false)) {  // Pas d'alerte affichée, notifications locales utilisées
            Alert(title: Text("Information"), message: Text(""), dismissButton: .default(Text("OK")))
        }
    }
    
    // Fonction pour déclencher une notification locale
    private func scheduleNotification(title: String, message: String) {
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
