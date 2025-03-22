import SwiftUI

struct MotPasseOublieView: View {
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let onRetourDynamic: () -> Void // 🔁 Retour dynamique vers la dernière page
    let onInscription: () -> Void

    var body: some View {
        VStack {
            // Bouton retour en haut à gauche
            HStack {
                Button(action: {
                    onRetourDynamic() // Retour vers la dernière page visitée
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
                    Text("RECUPERATION")
                        .font(.custom("Bangers", size: 30))

                    Image("lock")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .padding(.top, 5)

                    Text("Problèmes de connexion ?")
                        .font(.headline)

                    Text("Entrez votre adresse e-mail, votre numéro de téléphone ou votre nom d’utilisateur, et nous vous enverrons un lien pour récupérer votre compte.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)

                    Button(action: {
                        guard !email.isEmpty else {
                            alertMessage = "Veuillez entrer un email valide."
                            showAlert = true
                            return
                        }
                        // Préparation de la requête POST vers /mdp_oublie
                        guard let url = URL(string: "http://localhost:3000/mdp_oublie") else {
                            alertMessage = "URL invalide."
                            showAlert = true
                            return
                        }
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        let body: [String: Any] = ["email": email]
                        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                        
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                print("Erreur lors de la récupération du mot de passe: \(error)")
                                DispatchQueue.main.async {
                                    alertMessage = "Erreur: \(error.localizedDescription)"
                                    showAlert = true
                                }
                                return
                            }
                            // Vous pouvez éventuellement traiter la réponse ici
                            DispatchQueue.main.async {
                                alertMessage = "Un lien de réinitialisation du mot de passe a été envoyé à votre adresse."
                                showAlert = true
                            }
                        }.resume()
                        
                    }) {
                        Text("Récupération mot de passe")
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

                // Lien vers InscriptionView
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
            Alert(title: Text("Information"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
