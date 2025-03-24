import SwiftUI
import UserNotifications

/// Vue pour afficher et gérer les paiements aux vendeurs
struct PayerVendeurListeView: View {
    /// Email du vendeur concerné
    let email: String
    
    /// Callback pour retourner à la vue précédente
    let onRetour: () -> Void
    
    /// ViewModel contenant la logique métier
    @StateObject private var viewModel: PayerVendeurViewModel
    
    /// Initialisation de la vue avec l'email du vendeur
    init(email: String, onRetour: @escaping () -> Void) {
        self.email = email
        self.onRetour = onRetour
        self._viewModel = StateObject(wrappedValue: PayerVendeurViewModel(email: email))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Contenu principal
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 30)
                        
                        // En-tête avec bouton retour et titre
                        headerView
                        
                        // Message d'erreur
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Tableau des ventes
                        salesTableView(geometry: geometry)
                        
                        // Somme totale
                        Text("Somme totale : \(String(format: "%.2f", viewModel.sommeTotale)) €")
                            .font(.system(size: 18, weight: .bold))
                            .padding()
                        
                        // Bouton de paiement
                        payButton
                        
                        Spacer(minLength: 50)
                    }
                }
                
                // Overlay de chargement
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            viewModel.fetchHistorique()
        }
    }
    
    // MARK: - Sous-vues
    
    /// En-tête avec bouton retour et titre
    private var headerView: some View {
        HStack {
            Button(action: onRetour) {
                Image("retour")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding(.leading, 20)
            }
            Spacer()
            Text("Historique des ventes")
                .font(.system(size: 22, weight: .bold))
                .padding(.trailing, 50)
            Spacer()
        }
        .padding(.top, 10)
    }
    
    /// Tableau des ventes
    private func salesTableView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // En-tête du tableau
            HStack(spacing: 0) {
                cellHeader("Nom du Jeu", geometry: geometry)
                cellHeader("Qté vendue", geometry: geometry)
                cellHeader("Prix vendeur", geometry: geometry)
                cellHeader("Payé", geometry: geometry)
            }
            .frame(height: 40)
            .background(Color.gray.opacity(0.2))
            
            // Lignes du tableau
            ForEach(viewModel.historiqueVentes) { vente in
                HStack(spacing: 0) {
                    cellBody(vente.nomJeu, geometry: geometry)
                    cellBody("\(vente.quantiteVendue)", geometry: geometry)
                    cellBody(String(format: "%.2f€", vente.prixUnit), geometry: geometry)
                    cellBody(vente.vendeurPaye ? "Oui" : "Non", geometry: geometry)
                }
            }
        }
        .border(Color.black)
        .frame(width: geometry.size.width * 0.9)
        .padding(.horizontal, geometry.size.width * 0.05)
    }
    
    /// Bouton de paiement
    private var payButton: some View {
        Button(action: {
            viewModel.payerVendeur()
        }) {
            Text("Payer le vendeur")
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 17, weight: .bold))
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .disabled(viewModel.isLoading)
    }
    
    /// Overlay de chargement
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Chargement...")
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
            .padding(20)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Composants de tableau
    
    /// Calcule la largeur d'une colonne
    private func largeurColonne(_ geometry: GeometryProxy) -> CGFloat {
        (geometry.size.width * 0.9) / 4
    }
    
    /// Cellule d'en-tête du tableau
    private func cellHeader(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(width: largeurColonne(geometry), height: 40)
            .border(Color.black)
    }
    
    /// Cellule du corps du tableau
    private func cellBody(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 13))
            .multilineTextAlignment(.center)
            .frame(width: largeurColonne(geometry), height: 40)
            .border(Color.black)
    }
    
    // MARK: - Utilitaires
    
    /// Masque le clavier virtuel
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct PayerVendeurListeView_Previews: PreviewProvider {
    static var previews: some View {
        PayerVendeurListeView(email: "vendeur@example.com", onRetour: { })
    }
}