import SwiftUI
import UserNotifications

struct PreinscriptionView: View {
    @Binding var selectedView: String
    
    @State private var email: String = ""
    @State private var role: String = ""
    @State private var errorMessage: String = ""
    
    let roles = ["Vendeur", "Admin", "Acheteur", "Gestionnaire"]
    
    // Base URL de votre back
    let baseURL = BaseUrl.lien
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width,
                           height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        Spacer(minLength: 40)
                        
                        VStack(spacing: 10) {
                            Text("PREINSCRIRE")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .padding(.horizontal)
                            
                            Picker("Choisissez un rôle", selection: $role) {
                                Text("Choisissez un rôle").tag("")
                                ForEach(roles, id: \.self) { r in
                                    Text(r).tag(r)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            
                            // Affichage du message d'erreur
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                            
                            Button(action: {
                                // Réinitialisation du message d'erreur seulement
                                errorMessage = ""
                                
                                // Vérification de la validité de l'email
                                guard isValidEmail(email) else {
                                    errorMessage = "Veuillez entrer un email valide."
                                    return
                                }
                                // Vérification que le rôle a été sélectionné
                                guard !role.isEmpty else {
                                    errorMessage = "Veuillez sélectionner un rôle."
                                    return
                                }
                                preinscrire()
                            }) {
                                Text("PREINSCRIRE")
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
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                // Gestion des erreurs ou refus si nécessaire
            }
        }
    }
    
    // Fonction de validation d'email (validation simple via regex)
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
    
    private func preinscrire() {
        guard let url = URL(string: "\(baseURL)/preinscription") else {
            print("URL invalide pour préinscription")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "role": role]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la préinscription: \(error)")
                return
            }
            print("Préinscription réussie")
            DispatchQueue.main.async {
                scheduleLocalNotification()
                // Note : ici, on ne réinitialise pas email ni role,
                // ce qui permet de conserver les valeurs dans le formulaire.
            }
        }.resume()
    }
    
    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Préinscription effectuée"
        content.body = "Votre préinscription a été enregistrée avec succès."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct PreinscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PreinscriptionView(selectedView: .constant("Pré-Inscription"))
    }
}
