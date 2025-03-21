import SwiftUI

struct MotPasseOublieView: View {
    @State private var email: String = ""
    @State private var showAlert = false
    let onRetourDynamic: () -> Void // 🔁 Retour dynamique vers la dernière page
    let onInscription: () -> Void

    var body: some View {
        VStack {
            // 🔙 Bouton retour bien calé en haut à gauche
            HStack {
                Button(action: {
                    onRetourDynamic() // 🔥 Retourne dynamiquement vers la dernière page visitée
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

            // 🧩 Zone principale bien centrée
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
                        if email.isEmpty {
                            showAlert = true
                        } else {
                            print("Lien envoyé à : \(email)")
                        }
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

                // 🔗 Lien vers InscriptionView
                VStack {
                    HStack {
                        Text("Vous n'avez pas de compte ?")
                            .font(.footnote)

                        Button(action: {
                            onInscription() // 🔥 Redirection vers InscriptionView
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
            Alert(title: Text("Erreur"), message: Text("Veuillez entrer un email valide"), dismissButton: .default(Text("OK")))
        }
    }
}
