// WithdrawalListViewModel.swift

import Foundation
import Combine

class WithdrawalListViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    private let service = GestionnaireService()
    private var cancellables = Set<AnyCancellable>()
    
    let userEmail: String
    
    init(email: String) {
        self.userEmail = email
        fetchGames()
    }
    
    func fetchGames() {
        isLoading = true
        errorMessage = nil
        
        service.fetchJeux(email: userEmail)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors de la récupération des jeux: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] games in
                    self?.games = games
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleSelection(for game: Game) {
        guard let index = games.firstIndex(where: { $0.id_stock == game.id_stock }) else { return }
        games[index].isSelected.toggle()
    }
    
    func withdrawSelectedGames() {
        let selectedGames = games.filter { $0.isSelected }
        
        if selectedGames.isEmpty {
            alertMessage = "Veuillez sélectionner au moins un jeu à retirer."
            showAlert = true
            return
        }
        
        // Group games by ID for proper counting
        let groupedGames = Dictionary(grouping: selectedGames) { $0.id_stock }
        
        var withdrawalTasks: [AnyPublisher<Void, Error>] = []
        
        for (idStock, gamesWithSameId) in groupedGames {
            let request = WithdrawalRequest(
                id_stock: idStock,
                nombre_checkbox_selectionne_cet_id: gamesWithSameId.count
            )
            
            withdrawalTasks.append(service.retirerJeux(request))
        }
        
        // Use Combine to execute all tasks
        isLoading = true
        
        Publishers.MergeMany(withdrawalTasks)
            .collect()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = "Erreur lors du retrait des jeux: \(error.localizedDescription)"
                        self?.showAlert = true
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.successMessage = "Les jeux ont été retirés avec succès"
                    self?.showSuccess = true
                    
                    // Update the games list
                    self?.updateGamesAfterWithdrawal(selectedGames)
                }
            )
            .store(in: &cancellables)
    }
    
    private func updateGamesAfterWithdrawal(_ selectedGames: [Game]) {
        let groupedGames = Dictionary(grouping: selectedGames) { $0.id_stock }
        
        // Create a copy of the games array to modify
        var updatedGames = games
        
        for (idStock, gamesWithSameId) in groupedGames {
            // Find all instances with the same ID
            let withdrawalCount = gamesWithSameId.count
            let currentQuantity = games.first(where: { $0.id_stock == idStock })?.Quantite_actuelle ?? 0
            
            if withdrawalCount >= currentQuantity {
                // Remove the game entirely
                updatedGames.removeAll(where: { $0.id_stock == idStock })
            } else {
                // Update quantity
                if let index = updatedGames.firstIndex(where: { $0.id_stock == idStock }) {
                    updatedGames[index].Quantite_actuelle -= withdrawalCount
                    updatedGames[index].isSelected = false
                }
            }
        }
        
        // Update the published property
        games = updatedGames
    }
}