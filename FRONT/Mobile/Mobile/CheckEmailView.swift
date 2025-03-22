import SwiftUI

struct CheckEmailView: View {
    @State private var codeRecu: String = ""
    @State private var showAlert = false
    @State private var errorMessage: String? = nil

    let email: String
    let onRetour: () -> Void    // Retour uniquement vers InscriptionView
    let onInvité: () -> Void    // Redirection vers le mode invité
    // Callback appelé lorsque la vérification est réussie et qui fournit le rôle de l'utilisateur
    let onVerificationSuccess: (String) -> Void

    var body: some View {
        VStack {
            // Bouton retour en haut à gauche
            HStack {
                Button(action: {
                    onRetour() // Retour vers InscriptionView
                }) {
                    Image("retour")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)

            Spacer()

            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    Text("VÉRIFICATION EMAIL")
                        .font(.custom("Bangers", size: 30))

                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .padding(.top, 5)

                    Text("Confirmation de l'email")
                        .font(.headline)

                    Text("Afin de s'assurer qu'il s'agit bien de votre adresse email, veuillez entrer le code que vous venez de recevoir par e-mail.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    TextField("Code reçu par mail", text: $codeRecu)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .keyboardType(.numberPad)

                    Button(action: {
                        guard !codeRecu.isEmpty else {
                            errorMessage = "Veuillez entrer un code valide"
                            showAlert = true
                            return
                        }
                        // Appel au back pour vérifier le code
                        guard let url = URL(string: "http://localhost:3000/verification-email") else {
                            errorMessage = "URL invalide"
                            showAlert = true
                            return
                        }
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        let bodyDict: [String: Any] = [
                            "email": email,
                            "code_recu": codeRecu
                        ]
                        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
                        
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                DispatchQueue.main.async {
                                    errorMessage = "Erreur: \(error.localizedDescription)"
                                    showAlert = true
                                }
                                return
                            }
                            guard let data = data,
                                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                                DispatchQueue.main.async {
                                    errorMessage = "Réponse invalide du serveur."
                                    showAlert = true
                                }
                                return
                            }
                            
                            // Si le serveur renvoie un message, nous considérons que la vérification est réussie
                            if let message = json["message"] as? String {
                                print("Réponse verification-email: \(message)")
                                // Ensuite, appel à /api/user-info pour obtenir le rôle
                                guard let infoUrl = URL(string: "http://localhost:3000/api/user-info") else {
                                    DispatchQueue.main.async {
                                        errorMessage = "URL invalide pour user-info"
                                        showAlert = true
                                    }
                                    return
                                }
                                URLSession.shared.dataTask(with: infoUrl) { infoData, infoResponse, infoError in
                                    if let infoError = infoError {
                                        DispatchQueue.main.async {
                                            errorMessage = "Erreur user-info: \(infoError.localizedDescription)"
                                            showAlert = true
                                        }
                                        return
                                    }
                                    guard let infoData = infoData,
                                          let infoJson = try? JSONSerialization.jsonObject(with: infoData) as? [String: Any],
                                          let role = infoJson["role"] as? String else {
                                        DispatchQueue.main.async {
                                            errorMessage = "Impossible de récupérer le rôle."
                                            showAlert = true
                                        }
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        // Appel du callback avec le rôle obtenu
                                        onVerificationSuccess(role)
                                    }
                                }.resume()
                            } else {
                                DispatchQueue.main.async {
                                    errorMessage = "Code de vérification invalide."
                                    showAlert = true
                                }
                            }
                        }.resume()
                    }) {
                        Text("Vérifier")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(5)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 2)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9)

            Spacer()

            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 15)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Erreur"), message: Text(errorMessage ?? "Veuillez entrer un code valide"), dismissButton: .default(Text("OK")))
        }
    }
}

