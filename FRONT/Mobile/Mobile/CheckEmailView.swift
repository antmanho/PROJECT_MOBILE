import SwiftUI

struct CheckEmailView: View {
    @State private var codeRecu: String = ""
    @State private var showAlert = false
    let email: String
    let onRetour: () -> Void // 🔥 Retour uniquement vers InscriptionView
    let onInvité: () -> Void // 🔥 Redirection vers mode invité

    var body: some View {
        VStack {
            // 🔙 Bouton retour en haut à gauche (RETOUR → InscriptionView)
            HStack {
                Button(action: {
                    onRetour() // 🔥 Retourne uniquement vers InscriptionView
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
                        if codeRecu.isEmpty {
                            showAlert = true
                        } else {
                            print("Vérification réussie pour le code : \(codeRecu)")
                        }
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
            Alert(title: Text("Erreur"), message: Text("Veuillez entrer un code valide"), dismissButton: .default(Text("OK")))
        }
    }
}
