import SwiftUI

struct InscriptionView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil

    let onMotDePasseOublie: () -> Void // Callback vers MotPasseOublieView
    let onConnexion: () -> Void        // Callback vers ConnexionView
    let onCheckEmail: (String) -> Void // Callback pour rediriger vers CheckEmailView

    var body: some View {
        VStack {
            Spacer(minLength: 20)
            
            // Conteneur principal avec largeur réduite
            VStack(spacing: 16) {
                
                // Premier cadre (Inscription)
                VStack(spacing: 12) {
                    Text("INSCRIPTION")
                        .font(.custom("Bangers", size: 26))
                        .padding(.bottom, 6)
                    
                    VStack(spacing: 8) {
                        TextField("Email", text: $email)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            .autocapitalization(.none)
                        
                        SecureField("Mot de passe", text: $password)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                        
                        SecureField("Confirmation du mot de passe", text: $confirmPassword)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                        
                        Button(action: {
                            // Vérification des champs
                            guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                                errorMessage = "Veuillez remplir tous les champs"
                                return
                            }
                            guard password == confirmPassword else {
                                errorMessage = "Les mots de passe ne correspondent pas"
                                return
                            }
                            errorMessage = nil
                            
                            // Préparation de la requête POST vers /api/inscription
                            guard let url = URL(string: "\(BaseUrl.lien)/api/inscription") else {
                                errorMessage = "URL invalide"
                                return
                            }
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            
                            let body = [
                                "email": email,
                                "password": password,
                                "confirmPassword": confirmPassword
                            ]
                            
                            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                            
                            URLSession.shared.dataTask(with: request) { data, response, error in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        errorMessage = "Erreur : \(error.localizedDescription)"
                                    }
                                    return
                                }
                                
                                guard let data = data,
                                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                                    DispatchQueue.main.async {
                                        errorMessage = "Réponse invalide du serveur"
                                    }
                                    return
                                }
                                
                                if let message = json["message"] as? String {
                                    print("Message serveur : \(message)")
                                    DispatchQueue.main.async {
                                        onCheckEmail(email)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        errorMessage = "Inscription échouée"
                                    }
                                }
                            }.resume()
                            
                        }) {
                            Text("S'inscrire")
                                .foregroundColor(.white)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(5)
                        }
                        .padding(.top, 8)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                    }
                    .padding(10)
                    
                    DividerView2()
                    
                    Button(action: {
                        onMotDePasseOublie()
                    }) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
                
                // Deuxième cadre (Lien vers Connexion)
                VStack {
                    HStack {
                        Text("Vous avez déjà un compte ?")
                            .multilineTextAlignment(.center)
                        Button(action: {
                            onConnexion()
                        }) {
                            Text("Connectez-vous")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8) // largeur fixée à 80% de l'écran
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

struct DividerView2: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
            Text("OU")
                .padding(.horizontal, 10)
                .background(Color.white)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
        }
        .padding(.vertical, 2)
    }
}

