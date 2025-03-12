import Foundation
import Combine

struct LoginResponse: Decodable {
    let success: Bool
    let message: String?
    let redirectUrl: String
}

class AuthService {
    private let baseURL = "http://localhost:3000"
    
    func login(email: String, password: String) -> AnyPublisher<LoginResponse, Error> {
        guard let url = URL(string: "\(baseURL)/login") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create login payload
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}