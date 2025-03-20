import SwiftUI

struct ConnexionView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            Spacer()

            // Container parent qui fixe la largeur globale
            VStack(spacing: 20) {

                // Premier cadre
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
                            // Action de connexion
                            if email.isEmpty || password.isEmpty {
                                errorMessage = "Veuillez remplir tous les champs"
                            } else {
                                errorMessage = nil
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

                    Button(action: {
                        // Action mot de passe oublié
                    }) {
                        Text("Mot de passe oublié ?")
                            .foregroundColor(Color.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity) // Force le cadre à prendre toute la largeur du parent
                .border(Color.black, width: 2)

                // Deuxième cadre
                VStack {
                    HStack {
                        Text("Vous n'avez pas \n de compte ?")
                            .minimumScaleFactor(0.9)

                        Button(action: {
                            // Action inscription
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
                .frame(maxWidth: .infinity) // Force la même largeur que le premier cadre
                .border(Color.black, width: 2)

            }
            .frame(width: UIScreen.main.bounds.width * 0.9 ) // Largeur globale imposée
            .fixedSize(horizontal: false, vertical: true) // Évite les redimensionnements imprévus

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

struct ConnexionView_Previews: PreviewProvider {
    static var previews: some View {
        ConnexionView()
    }
}
