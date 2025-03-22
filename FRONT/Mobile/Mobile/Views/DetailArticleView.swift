import SwiftUI

/// Vue pour afficher les détails d'un article
struct DetailArticleView: View {
    /// ViewModel contenant la logique et les données
    @StateObject private var viewModel: DetailArticleViewModel
    
    /// Callback pour revenir en arrière
    var onBack: (() -> Void)? = nil
    
    /// Initialisation avec l'ID du jeu et le callback de retour
    init(gameId: Int, onBack: (() -> Void)? = nil) {
        self._viewModel = StateObject(wrappedValue: DetailArticleViewModel(gameId: gameId))
        self.onBack = onBack
    }
    
    var body: some View {
        VStack {
            // Entête avec bouton retour
            headerView
            
            // Contenu principal
            if viewModel.isLoading {
                loadingView
            } else if let product = viewModel.product {
                productDetailView(product)
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else {
                emptyStateView
            }
        }
        .onAppear {
            viewModel.fetchProductDetail()
        }
    }
    
    /// Vue d'entête avec le bouton retour
    private var headerView: some View {
        VStack {
            HStack {
                Button(action: {
                    onBack?()
                }) {
                    Image("retour")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            Text("DETAIL DU PRODUIT")
                .font(.title)
                .bold()
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
    }
    
    /// Vue de chargement
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Chargement...")
            Spacer()
        }
    }
    
    /// Vue d'erreur
    private func errorView(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .padding()
            Spacer()
        }
    }
    
    /// Vue d'état vide
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Aucun produit trouvé")
                .padding()
            Spacer()
        }
    }
    
    /// Vue de détail du produit
    private func productDetailView(_ product: GameDetail) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // En-tête du produit (image et informations principales)
                HStack(alignment: .top, spacing: 20) {
                    productImageView
                    productInfoView(product)
                }
                .padding(20)
                
                // Description si disponible
                if let description = product.description, !description.isEmpty {
                    productDescriptionView(description)
                }
            }
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .padding(.horizontal, 16)
        }
    }
    
    /// Vue de l'image du produit
    private var productImageView: some View {
        Group {
            if let url = viewModel.getFullImageUrl() {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                    case .failure(_):
                        Color.red
                            .frame(width: 150, height: 150)
                            .overlay(Text("Erreur").foregroundColor(.white))
                    default:
                        Color.gray
                            .frame(width: 150, height: 150)
                    }
                }
            } else {
                Color.gray
                    .frame(width: 150, height: 150)
            }
        }
    }
    
    /// Vue des informations principales du produit
    private func productInfoView(_ product: GameDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(product.nomJeu)
                .font(.headline)
                .foregroundColor(.primary)
            
            // "N°article:" en noir, numéro en secondaire
            HStack {
                Text("N°article: ")
                    .foregroundColor(.black)
                Text("\(product.id)")
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            // "Prix:" en noir, le prix en secondaire
            HStack {
                Text("Prix: ")
                    .foregroundColor(.black)
                Text(viewModel.formatPrice(product.prixUnit))
                    .foregroundColor(.secondary)
            }
            .font(.subheadline)
            
            // "Éditeur:" en noir, le nom de l'éditeur en secondaire (si disponible)
            if let editeur = product.editeur, !editeur.isEmpty {
                HStack {
                    Text("Éditeur: ")
                        .foregroundColor(.black)
                    Text(editeur)
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Vue de la description du produit
    private func productDescriptionView(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Description: ")
                    .foregroundColor(.black)
                Spacer()
            }
            .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(20)
    }
}

/// Prévisualisation pour Xcode
struct DetailArticleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailArticleView(gameId: 1, onBack: {
                // Action de retour pour la preview
            })
        }
    }
}