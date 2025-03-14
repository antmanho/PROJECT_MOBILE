// ManagerService.swift

import Foundation
import Combine

class ManagerService {
    private let baseURL = "http://localhost:3000"
    
    func fetchSellerSales(email: String) -> AnyPublisher<[SaleItem], Error> {
        guard let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/historique-ventes/\(encodedEmail)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SaleItem].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func paySeller(email: String) -> AnyPublisher<PaySellerResponse, Error> {
        guard let url = URL(string: "\(baseURL)/payer-vendeur") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["emailVendeur": email]
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PaySellerResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}