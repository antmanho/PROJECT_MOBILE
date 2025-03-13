// A déplacer dans les Services p-e
import Foundation
import Combine

class ProductService {
    private let baseURL = "http://localhost:3000"
    
    func fetchProductDetails(id: Int) -> AnyPublisher<Product, Error> {
        guard let url = URL(string: "\(baseURL)/api/product/\(id)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Product.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}