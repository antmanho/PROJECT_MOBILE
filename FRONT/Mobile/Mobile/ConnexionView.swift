import SwiftUI

struct ConnexionView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    let onMotDePasseOublie: () -> Void
    let onInscription: () -> Void
    let onLoginSuccess: (String) -> Void

    var body: some View {
        VStack {
            Spacer(minLength: 20)
            
            // Conteneur commun à largeur fixe
            VStack(spacing: 16) {
                // Premier cadre (Formulaire de connexion)
                VStack(spacing: 12) {
                    Text("CONNEXION")
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
                        
                        Button(action: {
                            guard !email.isEmpty, !password.isEmpty else {
                                errorMessage = "Veuillez remplir tous les champs"
                                return
                            }
                            errorMessage = nil
                            
                            // Requête de connexion
                            guard let url = URL(string: "\(BaseUrl.lien)/api/connexion") else {
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
                                
                                // Récupération du rôle via /api/user-info
                                guard let infoUrl = URL(string: "\(BaseUrl.lien)/api/user-info") else { return }
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
                                        onLoginSuccess(role)
                                    }
                                }.resume()
                                
                            }.resume()
                        }) {
                            Text("Se connecter")
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
                    
                    DividerView()
                    
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
                
                // Second cadre (Lien vers inscription)
                VStack {
                    HStack {
                        Text("Vous n'avez pas de compte ?")
                        Button(action: {
                            onInscription()
                        }) {
                            Text("Inscrivez-vous")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 20)
            
            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .center) // Centre le contenu
    }
}

struct DividerView: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
            Text("OU")
                .padding(.horizontal, 6)
                .background(Color.white)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black)
        }
        .padding(.vertical, 6)
    }
}
