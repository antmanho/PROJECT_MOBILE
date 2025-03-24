import SwiftUI

struct CatalogueView: View {
    // MARK: - Properties
    @StateObject private var viewModel: CatalogueViewModel
    var onGameSelected: (Game) -> Void
    
    let columns = [GridItem(.adaptive(minimum: 160), spacing: 10)]
    
    // MARK: - Initialization
    init(games: [Game] = [], onGameSelected: @escaping (Game) -> Void = { _ in }) {
        self._viewModel = StateObject(wrappedValue: CatalogueViewModel(initialGames: games))
        self.onGameSelected = onGameSelected
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header Section
            VStack(spacing: 10) {
                Text("CATALOGUE")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 10)
                
                // Search Bar
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
                        // Ouvrir les filtres ou réglages
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
            
            // MARK: - Content Section
            ZStack {
                // Main content - Game grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(viewModel.filteredGames) { game in
                            GameCardView(game: game, baseImageURL: viewModel.baseImageURL) {
                                onGameSelected(game)
                            }
                        }
                    }
                    .padding()
                }
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView("Chargement...")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
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
}

// MARK: - Game Card Subview
struct GameCardView: View {
    let game: Game
    let baseImageURL: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Text(game.nomJeu)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.vertical, 5)
                
                if let url = URL(string: baseImageURL + game.photoPath) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipped()
                        } else if phase.error != nil {
                            Image(systemName: "photo")
                                .frame(height: 150)
                                .background(Color.red.opacity(0.2))
                        } else {
                            ProgressView()
                                .frame(height: 150)
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                } else {
                    Color.gray.frame(height: 150)
                }
                
                VStack {
                    Text("N°article : \(game.id)")
                        .font(.subheadline)
                    Divider()
                    Text(String(format: "%.2f €", game.prixFinal))
                        .font(.subheadline)
                        .bold()
                }
                .padding(5)
            }
            .frame(width: 160)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .padding(5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews
struct CatalogueView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueView(
            games: [
                Game(id: 1, nomJeu: "Monopoly Édition Deluxe", prixUnit: 25.0, photoPath: "/IMAGE/Cluedo.JPG", 
                     fraisDepotFixe: 5, fraisDepotPercent: 10, prixFinal: 29.0, estEnVente: true),
                Game(id: 2, nomJeu: "Risk Game of Thrones", prixUnit: 35.0, photoPath: "/IMAGE/Risk.JPG", 
                     fraisDepotFixe: 5, fraisDepotPercent: 10, prixFinal: 39.0, estEnVente: true)
            ],
            onGameSelected: { game in
                print("Jeu sélectionné: \(game.nomJeu)")
            }
        )
    }
}

// MARK: - Cache toujours le clavier
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}