import Foundation
import Combine

class AuthService: ObservableObject {
    private let baseUrl = "http://localhost:3000"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Session configuration unique
    private var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = true
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpCookieStorage = .shared
        return URLSession(configuration: configuration)
    }()

    // Vérifie si l'utilisateur a le rôle vendeur
    func verifyVendorRole() -> AnyPublisher<Bool, Error> {
        verifyRole(endpoint: "/verification_V")
    }
    
    // Vérifie si l'utilisateur a le rôle admin
    func verifyAdminRole() -> AnyPublisher<Bool, Error> {
        verifyRole(endpoint: "/verification_A")
    }
    
    // Vérifie si l'utilisateur est manager ou admin
    func verifyManagerOrAdminRole() -> AnyPublisher<Bool, Error> {
        verifyRole(endpoint: "/verification_G_ou_A")
    }
    
    // Méthode générique de vérification de rôle
    private func verifyRole(endpoint: String) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: baseUrl + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, self.httpResponseIsValid(httpResponse) else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: RoleVerificationResponse.self, decoder: JSONDecoder())
            .map { $0.valid }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Vérifie la validité d'une réponse HTTP
    private func httpResponseIsValid(_ response: HTTPURLResponse) -> Bool {
        return (200...299).contains(response.statusCode)
    }
}

// Réponse pour vérification du rôle
struct RoleVerificationResponse: Decodable {
    let valid: Bool
}
