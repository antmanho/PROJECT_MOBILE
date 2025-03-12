import Foundation
import Combine

class NetworkManager: ObservableObject {
    @Published var isConnected: Bool = true
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "https://your-api-endpoint.com"
    
    // Generic fetch method
    func fetch<T: Decodable>(endpoint: String) -> AnyPublisher<T, Error> {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        self.isLoading = true
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            })
            .eraseToAnyPublisher()
    }
    
    // Specific API methods
    func fetchGames() -> AnyPublisher<[Game], Error> {
        return fetch(endpoint: "games")
    }
    
    // Could add more methods like login, register, etc.
}