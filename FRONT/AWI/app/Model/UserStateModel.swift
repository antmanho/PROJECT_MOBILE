import Foundation
import Combine

class UserStateModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var emailConnecte: String = "invite@example.com"
    @Published var role: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService()
    
    init() {
        getUserInfo()
    }
    
    func getUserInfo() {
        apiService.getUserInfo()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Erreur lors de la récupération des informations utilisateur:", error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.emailConnecte = response.email
                    self?.role = response.role
                    self?.isAuthenticated = response.email != "invite@example.com"
                }
            )
            .store(in: &cancellables)
    }
    
    func deconnexion() {
        apiService.logout()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Erreur lors de la déconnexion:", error)
                    }
                },
                receiveValue: { [weak self] response in
                    print(response.message)
                    self?.emailConnecte = "invite@example.com"
                    self?.role = ""
                    self?.isAuthenticated = false
                    // Since we can't reload the app like in web, reset navigation state instead
                    NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            )
            .store(in: &cancellables)
    }
}

// API Service
class APIService {
    private let baseURL = "http://localhost:3000"
    
    func getUserInfo() -> AnyPublisher<UserInfoResponse, Error> {
        guard let url = URL(string: "\(baseURL)/userinfo") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: UserInfoResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<LogoutResponse, Error> {
        guard let url = URL(string: "\(baseURL)/logout") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: LogoutResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// Response models
struct UserInfoResponse: Decodable {
    let email: String
    let role: String
}

struct LogoutResponse: Decodable {
    let message: String
}

// Custom notification name
extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}