import SwiftUI



struct ConnexionView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    // 🔁 Callbacks pour navigation
    let onMotDePasseOublie: () -> Void
    let onInscription: () -> Void
    // Callback appelé lorsque la connexion est réussie, avec le rôle obtenu
    let onLoginSuccess: (String) -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                VStack {
                    Text("CONNEXION")
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

                        Button(action: {
                            guard !email.isEmpty, !password.isEmpty else {
                                errorMessage = "Veuillez remplir tous les champs"
                                return
                            }
                            errorMessage = nil
                            
                            // Préparation de la requête de connexion
                            guard let url = URL(string: "http://localhost:3000/api/connexion") else {
                                errorMessage = "URL invalide"
                                return
                            }
                            var request = URLRequest(url: url)
                            request.httpMethod = "POST"
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            
                            let body = ["email": email, "password": password]
                            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                            
                            URLSession.shared.dataTask(with: request) { data, response, error in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        errorMessage = "Erreur : \(error.localizedDescription)"
                                    }
                                    return
                                }
                                guard let data = data,
                                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                      let success = json["success"] as? Bool, success == true else {
                                    DispatchQueue.main.async {
                                        errorMessage = "Connexion échouée. Vérifiez vos identifiants."
                                    }
                                    return
                                }
                                
                                // Si connexion réussie, appel à /api/user-info pour obtenir le rôle
                                guard let infoUrl = URL(string: "http://localhost:3000/api/user-info") else { return }
                                URLSession.shared.dataTask(with: infoUrl) { infoData, infoResponse, infoError in
                                    if let infoError = infoError {
                                        DispatchQueue.main.async {
                                            errorMessage = "Erreur info: \(infoError.localizedDescription)"
                                        }
                                        return
                                    }
                                    guard let infoData = infoData,
                                          let infoJson = try? JSONSerialization.jsonObject(with: infoData) as? [String: Any],
                                          let role = infoJson["role"] as? String else {
                                        DispatchQueue.main.async {
                                            errorMessage = "Impossible de récupérer le rôle."
                                        }
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        // Appel du callback avec le rôle obtenu
                                        onLoginSuccess(role)
                                    }
                                }.resume()
                                
                            }.resume()
                        }) {
                            Text("Se connecter")
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

                    DividerView()

                    // 🔗 Lien "Mot de passe oublié"
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

                // 🔗 Lien vers InscriptionView
                VStack {
                    HStack {
                        Text("Vous n'avez pas de compte ?")
                            .minimumScaleFactor(0.9)

                        Button(action: {
                            onInscription() // Redirection vers InscriptionView
                        }) {
                            Text("Inscrivez-vous")
                                .foregroundColor(.blue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
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


struct DividerView: View {
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
        .padding(.vertical, 10)
    }
}
