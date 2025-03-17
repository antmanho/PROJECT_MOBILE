import Foundation
import Combine

class SessionService {
    private let baseURL = "http://localhost:3000"
    
    func createSession(_ session: SessionRequest) -> AnyPublisher<SessionResponse, Error> {
        guard let url = URL(string: "\(baseURL)/create-session") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(session)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: SessionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

struct SessionResponse: Codable {
    let success: Bool
    let message: String?
}