import SwiftUI

/// Vue pour rechercher un vendeur et afficher son historique de ventes
struct PayerVendeurView: View {
    /// ViewModel pour la gestion de la recherche
    @StateObject private var viewModel = VendorSearchViewModel()
    
    /// Callback pour naviguer vers l'historique des achats
    let onAfficherHistorique: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Arrière-plan
                backgroundImage(geometry: geometry)
                
                // Contenu principal
                ScrollView {
                    VStack {
                        Spacer(minLength: 40)
                        
                        // Carte du formulaire
                        formCard
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Sous-vues
    
    /// Image d'arrière-plan
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        Image("sport")
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
    }
    
    /// Carte contenant le formulaire
    private var formCard: some View {
        VStack(spacing: 10) {
            // Titre
            Text("PAYER VENDEUR")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 10)
            
            // Champ email vendeur
            emailField
            
            // Message d'erreur
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            // Bouton pour voir l'historique
            historyButton
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white.opacity(0.97))
        .cornerRadius(15)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 3)
        )
    }
    
    /// Champ de saisie d'email
    private var emailField: some View {
        TextField("Email du vendeur", text: $viewModel.emailVendeur)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    /// Bouton pour voir l'historique
    private var historyButton: some View {
        Button {
            viewModel.validateAndShowHistory(completion: onAfficherHistorique)
        } label: {
            Text("Voir Historique des achats")
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 20))
                .background(viewModel.isEmailValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!viewModel.isEmailValid)
        .padding(.horizontal)
    }
    
    // MARK: - Utilitaires
    
    /// Masque le clavier virtuel
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct PayerVendeurView_Previews: PreviewProvider {
    static var previews: some View {
        PayerVendeurView { email in
            print("Afficher l'historique pour : \(email)")
        }
    }
}