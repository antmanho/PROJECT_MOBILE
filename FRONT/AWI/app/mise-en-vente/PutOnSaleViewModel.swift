import Foundation
import Combine

class PutOnSaleViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var filteredGames: [Game] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let service = ManagerService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Set up search filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [weak self] searchText in
                guard let self = self, !searchText.isEmpty else {
                    return self?.games ?? []
                }
                
                return self.games.filter { game in
                    game.nom_jeu.lowercased().contains(searchText.lowercased()) ||
                    String(game.id_stock).contains(searchText)
                }
            }
            .assign(to: &$filteredGames)
    }
    
    func fetchCatalogue() {
        isLoading = true
        errorMessage = nil
        
        service.fetchCatalogue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du chargement du catalogue: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    self?.games = response.results
                    self?.filteredGames = response.results
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleEnVente(_ game: Game) {
        guard let index = games.firstIndex(where: { $0.id == game.id }) else { return }
        
        service.toggleEnVente(game)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("Erreur lors de la mise à jour du statut de vente:", error)
                        self?.errorMessage = "Erreur lors de la mise à jour du statut de vente"
                    }
                },
                receiveValue: { [weak self] _ in
                    // Update the local state when successful
                    var updatedGame = game
                    updatedGame.est_en_vente.toggle()
                    
                    self?.games[index] = updatedGame
                    
                    // Also update in filtered list if present
                    if let filteredIndex = self?.filteredGames.firstIndex(where: { $0.id == game.id }) {
                        self?.filteredGames[filteredIndex] = updatedGame
                    }
                }
            )
            .store(in: &cancellables)
    }
}