import Foundation
import Combine

class AuthService: ObservableObject {
    private let baseUrl = "http://localhost:3000"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Network session with credentials support
    private var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpCookieStorage = .shared
        return URLSession(configuration: configuration)
    }
    
    // Verify if user has Vendor role
    func verifyVendorRole() -> AnyPublisher<Bool, Error> {
        return verifyRole(endpoint: "/verification_V")
    }
    
    // Verify if user has Admin role
    func verifyAdminRole() -> AnyPublisher<Bool, Error> {
        return verifyRole(endpoint: "/verification_A")
    }
    
    // Verify if user has either Manager or Admin role
    func verifyManagerOrAdminRole() -> AnyPublisher<Bool, Error> {
        return verifyRole(endpoint: "/verification_G_ou_A")
    }
    
    // Generic role verification
    private func verifyRole(endpoint: String) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: baseUrl + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: RoleVerificationResponse.self, decoder: JSONDecoder())
            .map { $0.valid }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// Response type for role verification
struct RoleVerificationResponse: Decodable {
    let valid: Bool
}