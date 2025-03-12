import SwiftUI

struct CatalogueView: View {
    @StateObject private var viewModel = CatalogueViewModel()
    @State private var searchText = ""
    
    // Grille adaptative pour les cartes
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
    ]
    
    var filteredGames: [Game] {
        if searchText.isEmpty {
            return viewModel.games
        } else {
            return viewModel.games.filter { $0.nom_jeu.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // En-tête avec titre
                VStack {
                    Text("CATALOGUE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // Barre de recherche xD
                    HStack {
                        TextField("Rechercher un jeu", text: $searchText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
                .background(Color.white)
                .shadow(radius: 2)
                
                // Contenu principal - Grille de jeux du catalogue
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView("Chargement du catalogue...")
                            .padding()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredGames) { game in
                                NavigationLink(destination: GameDetailView(gameId: game.id_stock)) {
                                    GameCardView(game: game)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(hex: "#f4f4f4"))
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchCatalogue()
            }
        }
    }
}

// Composant pour la carte de jeu
struct GameCardView: View {
    let game: Game
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(game.nom_jeu)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.top, 8)
            
            if let imageUrl = game.imageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .imageScale(.large)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 120)
                .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("N°article : \(game.id_stock)")
                    .font(.caption)
                
                Text("------------------------")
                    .font(.caption)
                
                Text("\(String(format: "%.2f", game.prix_final)) €")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 4)
        .scaleEffect(isPressed ? 1.03 : 1.0)
        .animation(.spring(), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }
        }
    }
}

// Vue de détail pour un jeu (à implémenter parce que la je fais que le catalogue en speed)
struct GameDetailView: View {
    let gameId: Int
    
    var body: some View {
        Text("Détails du jeu \(gameId)")
            .navigationTitle("Détail de l'article")
    }
}

// Extension comme dans le cours d'aujourd'hui (partie 5) pour convertir les codes hexadécimaux en Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Prévisualisation pour le développement
struct CatalogueView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueView()
    }
}