import SwiftUI

struct PutOnSaleView: View {
    @StateObject private var viewModel = PutOnSaleViewModel()
    @State private var showFilterOptions = false
    
    // Grid layout for different device sizes
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    catalogueView
                }
            }
            .overlay(
                backToTopButton
            )
        }
        .onAppear {
            viewModel.fetchCatalogue()
        }
        .navigationTitle("Mise en Vente")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        Color(UIColor.systemGroupedBackground)
            .ignoresSafeArea()
    }
    
    // MARK: - Header Views
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("MISE EN VENTE")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.vertical)
            
            searchBarView
        }
        .padding(.horizontal)
        .background(Color.white)
    }
    
    private var searchBarView: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Rechercher...", text: $viewModel.searchText)
                    .font(.body)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            Button(action: {
                showFilterOptions.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
            }
            .sheet(isPresented: $showFilterOptions) {
                // Filter options view would go here
                Text("Options de filtrage")
                    .padding()
            }
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Main Content Views
    
    private var catalogueView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredGames) { game in
                    GameCardView(game: game, toggleAction: {
                        viewModel.toggleEnVente(game)
                    })
                }
            }
            .padding()
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Chargement des jeux...")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding()
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                viewModel.fetchCatalogue()
            }) {
                Text("Réessayer")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private var backToTopButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Button(action: {
                    // Scroll would be handled with ScrollViewReader
                    // in a production app
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 4)
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

// MARK: - Game Card View

struct GameCardView: View {
    let game: Game
    let toggleAction: () -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            // Game image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: game.imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                ProgressView()
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .frame(height: 150)
            
            VStack(alignment: .leading, spacing: 8) {
                // Game name
                Text(game.nom_jeu)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Text("N°article : \(game.id_stock)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Price
                Text("\(String(format: "%.2f", game.prix_final)) €")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Toggle switch
                HStack {
                    Text("Pas en vente")
                        .font(.caption)
                        .foregroundColor(!game.est_en_vente ? .gray : Color(.lightGray))
                    
                    Toggle("", isOn: .constant(game.est_en_vente))
                        .labelsHidden()
                        .tint(.green)
                        .onChange(of: game.est_en_vente) { newValue in
                            toggleAction()
                        }
                    
                    Text("En vente")
                        .font(.caption)
                        .foregroundColor(game.est_en_vente ? .green : Color(.lightGray))
                }
                .padding(.vertical, 4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

// MARK: - Preview Provider

struct PutOnSaleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PutOnSaleView()
        }
    }
}