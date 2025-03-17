import Foundation
import Combine

class CatalogueViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchCatalogue() {
        guard let url = URL(string: "http://localhost:3000/catalogue") else {
            self.errorMessage = "URL invalide"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CatalogueResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case let .failure(error) = completion {
                        self?.errorMessage = "Erreur: \(error.localizedDescription)"
                    }
                },
                receiveValue: { [weak self] response in
                    self?.games = response.results.filter { $0.est_en_vente == 1 }
                }
            )
            .store(in: &cancellables)
    }
}