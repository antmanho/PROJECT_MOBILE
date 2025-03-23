import SwiftUI
import UserNotifications

/// Vue pour la récupération de mot de passe
struct MotPasseOublieView: View {
    /// ViewModel contenant la logique métier
    @StateObject private var viewModel = MotPasseOublieViewModel()
    
    /// Callbacks pour la navigation
    let onRetourDynamic: () -> Void   // Retour vers la page précédente
    let onInscription: () -> Void     // Navigation vers l'inscription
    
    var body: some View {
        VStack {
            // En-tête avec bouton retour
            headerView
            
            Spacer(minLength: 20)
            
            // Contenu principal
            VStack(spacing: 12) {
                // Formulaire de récupération
                recoveryFormView
                
                // Lien vers l'inscription
                registrationLinkView
            }
            .frame(width: UIScreen.main.bounds.width * 0.8)
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 20)
            
            // Pied de page
            footerView
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            viewModel.requestNotificationPermission()
        }
    }
    
    // MARK: - Sous-vues
    
    /// En-tête avec bouton retour
    private var headerView: some View {
        HStack {
            Button(action: {
                onRetourDynamic()
            }) {
                Image("retour")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .padding(6)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Formulaire de récupération de mot de passe
    private var recoveryFormView: some View {
        VStack(spacing: 8) {
            Text("RÉCUPÉRATION")
                .font(.custom("Bangers", size: 26))
            
            Image("lock")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .padding(.top, 4)
            
            Text("Problèmes de connexion ?")
                .font(.headline)
            
            Text("Entrez votre adresse e-mail et nous vous enverrons un lien pour récupérer votre compte.")
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
            
            TextField("Email", text: $viewModel.email)
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            // Messages d'erreur ou de succès
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 4)
            }
            
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.top, 4)
            }
            
            Button(action: {
                viewModel.resetPassword()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    Text("Récupération mot de passe")
                }
                .foregroundColor(.white)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(viewModel.isEmailValid ? Color.blue : Color.gray)
                .cornerRadius(5)
            }
            .disabled(viewModel.isLoading || !viewModel.isEmailValid)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .border(Color.black, width: 1)
    }
    
    /// Vue avec lien vers l'inscription
    private var registrationLinkView: some View {
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
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .border(Color.black, width: 1)
    }
    
    /// Pied de page
    private var footerView: some View {
        Text("Barbedet Anthony & Delclaud Corentin production | Polytech school | © 2024 Boardland")
            .font(.footnote)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.bottom, 18)
    }
    
    // MARK: - Méthodes utilitaires
    
    /// Masque le clavier virtuel
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct MotPasseOublieView_Previews: PreviewProvider {
    static var previews: some View {
        MotPasseOublieView(
            onRetourDynamic: {},
            onInscription: {}
        )
    }
}