import SwiftUI

/// Vue pour la mise en vente et la gestion des jeux
struct MiseEnVenteView: View {
    /// ViewModel contenant la logique et les données
    @StateObject private var viewModel = MiseEnVenteViewModel()
    
    /// Configuration de la grille
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    
    /// Callback lorsqu'un jeu est sélectionné
    var onGameSelected: (Game) -> Void = { _ in }
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête avec titre et recherche
            headerView
            
            // Contenu principal
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(errorMessage)
            } else if viewModel.filteredGames.isEmpty {
                emptyStateView
            } else {
                gameGridView
            }
            
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .background(Color(UIColor.systemGray6))
        .onAppear {
            viewModel.fetchCatalogue()
        }
    }
    
    // MARK: - Sous-vues
    
    /// En-tête avec titre et barre de recherche
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("MISE EN VENTE")
                .font(.largeTitle)
                .bold()
                .padding(.top, 10)
            
            HStack(spacing: 10) {
                TextField("Rechercher...", text: $viewModel.searchText)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                    )
                
                Button(action: {
                    // Action de recherche
                }) {
                    Image("rechercher")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 40, height: 40)
                
                Button(action: {
                    // Action filtre/réglages
                }) {
                    Image("reglage")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 40, height: 40)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.white)
    }
    
    /// Indicateur de chargement
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            Text("Chargement du catalogue...")
                .padding(.top, 10)
            Spacer()
        }
    }
    
    /// Message d'erreur avec bouton pour réessayer
    private func errorView(_ message: String) -> some View {
        VStack {
            Spacer()
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            Button("Réessayer") {
                viewModel.fetchCatalogue()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            Spacer()
        }
        .padding()
    }
    
    /// Message quand aucun jeu n'est trouvé
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Text("Aucun jeu trouvé")
                .font(.headline)
            Spacer()
        }
    }
    
    /// Grille des jeux
    private var gameGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.filteredGames.indices, id: \.self) { index in
                    gameCardView(index: index)
                }
            }
            .padding()
        }
    }
    
    /// Carte d'un jeu individuel
    private func gameCardView(index: Int) -> some View {
        let game = viewModel.filteredGames[index]
        
        return Button(action: {
            onGameSelected(game)
        }) {
            VStack(spacing: 0) {
                // Titre du jeu
                Text(game.nomJeu)
                    .font(.headline)
                    .lineLimit(1)
                    .padding(.vertical, 5)
                
                // Image du jeu
                if let url = viewModel.getFullImageURL(path: game.photoPath) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                        } else if phase.error != nil {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 50)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .frame(height: 150)
                        } else {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                } else {
                    Color.gray
                        .frame(height: 150)
                }
                
                // Détails du jeu
                VStack {
                    Text("N°article : \(game.id)")
                        .font(.subheadline)
                    Divider()
                    Text(game.prixFormatte)
                        .font(.subheadline)
                    Toggle("En vente", isOn: Binding(
                        get: { game.estEnVente },
                        set: { newValue in viewModel.toggleEnVente(index: index, newValue: newValue) }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(5)
            }
            .frame(width: 160)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .clipped()
            .padding(5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Méthodes utilitaires
    
    /// Masque le clavier virtuel
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation pour Xcode
struct MiseEnVenteView_Previews: PreviewProvider {
    static var previews: some View {
        MiseEnVenteView()
    }
}