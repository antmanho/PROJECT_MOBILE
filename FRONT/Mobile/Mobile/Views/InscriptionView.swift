import SwiftUI

/// Vue pour l'inscription des utilisateurs
struct InscriptionView: View {
    /// ViewModel contenant toute la logique
    @StateObject private var viewModel = InscriptionViewModel()
    
    /// Callbacks pour la navigation
    let onMotDePasseOublie: () -> Void // Callback vers MotPasseOublieView
    let onConnexion: () -> Void        // Callback vers ConnexionView
    let onCheckEmail: (String) -> Void // Callback pour rediriger vers CheckEmailView

    var body: some View {
        VStack {
            Spacer(minLength: 20)
            
            // Conteneur principal avec largeur réduite
            VStack(spacing: 16) {
                // Premier cadre (Inscription)
                inscriptionFormView
                
                // Deuxième cadre (Lien vers Connexion)
                connexionLinkView
            }
            .frame(width: UIScreen.main.bounds.width * 0.8) // largeur fixée à 80% de l'écran
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            footerView
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    /// Formulaire d'inscription
    private var inscriptionFormView: some View {
        VStack(spacing: 12) {
            Text("INSCRIPTION")
                .font(.custom("Bangers", size: 26))
                .padding(.bottom, 6)
            
            VStack(spacing: 8) {
                // Champs de saisie
                TextField("Email", text: $viewModel.email)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Mot de passe", text: $viewModel.password)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                
                SecureField("Confirmation du mot de passe", text: $viewModel.confirmPassword)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                
                // Bouton d'inscription
                Button(action: {
                    viewModel.register(onSuccess: onCheckEmail)
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Text("S'inscrire")
                            .foregroundColor(.white)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                    }
                }
                .background(viewModel.isFormValid ? Color.blue : Color.gray)
                .cornerRadius(5)
                .padding(.top, 8)
                .disabled(viewModel.isLoading || !viewModel.isFormValid)
                
                // Message d'erreur
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
            }
            .padding(10)
            
            DividerView2()
            
            // Bouton mot de passe oublié
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
    }
    
    /// Vue du lien de connexion
    private var connexionLinkView: some View {
        VStack {
            HStack {
                Text("Vous avez déjà un compte ?")
                    .multilineTextAlignment(.center)
                Button(action: {
                    onConnexion()
                }) {
                    Text("Connectez-vous")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .border(Color.black, width: 1)
    }
    
    /// Vue du pied de page
    private var footerView: some View {
        Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
            .font(.footnote)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
    }
    
    /// Masque le clavier virtuel
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Séparateur visuel avec texte "OU"
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

/// Prévisualisation pour Xcode
struct InscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        InscriptionView(
            onMotDePasseOublie: {},
            onConnexion: {},
            onCheckEmail: { _ in }
        )
    }
}