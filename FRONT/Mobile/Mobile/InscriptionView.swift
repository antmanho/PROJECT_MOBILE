import SwiftUI

struct InscriptionView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            Spacer()

            // Container principal
            VStack(spacing: 20) {

                // Premier cadre (Inscription)
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
                            // Vérification des champs
                            if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                                errorMessage = "Veuillez remplir tous les champs"
                            } else if password != confirmPassword {
                                errorMessage = "Les mots de passe ne correspondent pas"
                            } else {
                                errorMessage = nil
                                print("Inscription réussie avec : \(email)")
                            }
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

                    Button(action: {
                        // Action mot de passe oublié (si nécessaire)
                    }) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(Color.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .border(Color.black, width: 2)

                // Deuxième cadre (Lien vers Connexion)
                VStack {
                    HStack {
                        Text("Vous avez déjà un compte ?")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(action: {
                            // Action pour naviguer vers la connexion
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

struct InscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        InscriptionView()
    }
}

// DividerView identique à ConnexionView
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
