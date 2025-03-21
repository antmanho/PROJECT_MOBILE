import SwiftUI



struct ConnexionView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    // 🔁 Callbacks pour navigation
    let onMotDePasseOublie: () -> Void
    let onInscription: () -> Void // 👈 Ajout du callback pour aller vers InscriptionView

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
                            if email.isEmpty || password.isEmpty {
                                errorMessage = "Veuillez remplir tous les champs"
                            } else {
                                errorMessage = nil
                                // Logique de connexion
                            }
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
                            onInscription() // 🔥 Redirection vers InscriptionView
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
