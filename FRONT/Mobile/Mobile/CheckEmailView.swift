import SwiftUI

struct CheckEmailView: View {
    @State private var codeRecu: String = ""
    @State private var errorMessage: String? = nil

    let email: String
    let onRetour: () -> Void
    let onInvité: () -> Void
    let onVerificationSuccess: (String) -> Void

    var body: some View {
        VStack {
            // Bouton retour en haut à gauche
            HStack {
                Button(action: {
                    onRetour()
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
            
            // Conteneur commun à largeur fixe
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    Text("VÉRIFICATION EMAIL")
                        .font(.custom("Bangers", size: 26))
                    
                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .padding(.top, 4)
                    
                    Text("Confirmation de l'email")
                        .font(.headline)
                    
                    Text("Afin de confirmer votre adresse, entrez le code reçu par e-mail.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                    
                    TextField("Code reçu", text: $codeRecu)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .keyboardType(.numberPad)
                    
                    Button(action: {
                        guard !codeRecu.isEmpty else {
                            errorMessage = "Veuillez entrer un code valide"
                            return
                        }
                        // Appel du backend pour vérifier le code...
                        guard let url = URL(string: "\(BaseUrl.lien)/verification-email") else {
                            errorMessage = "URL invalide"
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
                                }
                                return
                            }
                            
                            guard let data = data,
                                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                                DispatchQueue.main.async {
                                    errorMessage = "Réponse invalide du serveur."
                                }
                                return
                            }
                            
                            if let message = json["message"] as? String {
                                print("Réponse verification-email: \(message)")
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
                                        onVerificationSuccess(role)
                                    }
                                }.resume()
                            } else {
                                DispatchQueue.main.async {
                                    errorMessage = "Code de vérification invalide."
                                }
                            }
                        }.resume()
                        
                    }) {
                        Text("Vérifier")
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(5)
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            
            Spacer(minLength: 20)
            
            Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .alert(isPresented: .constant(false)) {  // Les notifications locales sont utilisées
            Alert(title: Text("Erreur"), message: Text(errorMessage ?? "Veuillez entrer un code valide"), dismissButton: .default(Text("OK")))
        }
    }
}
