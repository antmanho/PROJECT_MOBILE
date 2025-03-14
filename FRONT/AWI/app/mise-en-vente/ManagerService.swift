import Foundation
import Combine

class ManagerService {
    private let baseURL = "http://localhost:3000"
    
    func fetchCatalogue() -> AnyPublisher<CatalogueResponse, Error> {
        guard let url = URL(string: "\(baseURL)/catalogue") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CatalogueResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func toggleEnVente(_ game: Game) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/toggleEnVente/\(game.id_stock)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "est_en_vente": !game.est_en_vente
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () } // Ignore response data
            .catch { error -> AnyPublisher<Void, Error> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}