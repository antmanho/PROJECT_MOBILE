//mettre dans les Services
import Foundation
import Combine

class ManagerService {
    private let baseURL = "http://localhost:3000"
    
    func registerPurchase(_ purchase: Purchase) -> AnyPublisher<PurchaseResponse, Error> {
        guard let url = URL(string: "\(baseURL)/purchase") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(purchase)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PurchaseResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}