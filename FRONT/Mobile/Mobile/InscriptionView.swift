import SwiftUI
struct InscriptionView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil

    let onMotDePasseOublie: () -> Void // Callback vers MotPasseOublieView
    let onConnexion: () -> Void        // Callback vers ConnexionView
    // Callback modifié pour recevoir l'email et rediriger vers CheckEmailView
    let onCheckEmail: (String) -> Void

    var body: some View {
        VStack {
            Spacer()

            // 🧩 Zone principale centrée
            VStack(spacing: 20) {

                // 🔵 Premier cadre (Inscription)
                VStack {
                    Text("INSCRIPTION")
                        .font(.custom("Bangers", size: 30))
                        .padding(.bottom, 10)

                    VStack {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            .autocapitalization(.none)

                        SecureField("Mot de passe", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)

                        SecureField("Confirmation du mot de passe", text: $confirmPassword)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)

                        Button(action: {
                            // Vérifier que tous les champs sont remplis et que les mots de passe correspondent
                            guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                                errorMessage = "Veuillez remplir tous les champs"
                                return
                            }
                            guard password == confirmPassword else {
                                errorMessage = "Les mots de passe ne correspondent pas"
                                return
                            }
                            errorMessage = nil
                            
                            // Préparer la requête POST vers /api/inscription
                            guard let url = URL(string: "http://localhost:3000/api/inscription") else {
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
                                
                                // Vérification de la réponse du serveur
                                if let message = json["message"] as? String {
                                    print("Message serveur : \(message)")
                                    DispatchQueue.main.async {
                                        // En cas de succès, on appelle le callback en passant l'email
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
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(5)
                        }
                        .padding(.top, 10)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 5)
                        }
                    }
                    .padding()

                    DividerView2()

                    // 🔥 Bouton qui ouvre MotPasseOublieView
                    Button(action: {
                        onMotDePasseOublie()
                    }) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(Color.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 2)

                // 🔵 Deuxième cadre (Lien vers Connexion)
                VStack {
                    HStack {
                        Text("Vous avez déjà un compte ?")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(action: {
                            onConnexion()
                        }) {
                            Text("Connectez-vous")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 2)

            }
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 15)
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
