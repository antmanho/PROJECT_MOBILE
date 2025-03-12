import Foundation
import Combine

class AuthService: ObservableObject {
    private let baseURL = "http://localhost:3000"
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
    
    // MARK: - Login Functionality
    
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
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Registration Functionality
    
    func register(email: String, password: String, confirmPassword: String) -> AnyPublisher<RegisterResponse, Error> {
        guard let url = URL(string: "\(baseURL)/register") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "new_email": email,
            "new_password": password,
            "confirm_password": confirmPassword
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: RegisterResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Role Verification
    
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
        guard let url = URL(string: baseURL + endpoint) else {
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
    
    // MARK: - Password Management
    
    func changePassword(currentPassword: String, newPassword: String, confirmNewPassword: String) -> AnyPublisher<PasswordChangeResponse, Error> {
        guard let url = URL(string: "\(baseURL)/user/change-password") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request body
        let body: [String: String] = [
            "currentPassword": currentPassword,
            "newPassword": newPassword,
            "confirmPassword": confirmNewPassword
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PasswordChangeResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Password Reset
    
    func requestPasswordReset(email: String) -> AnyPublisher<PasswordResetResponse, Error> {
        guard let url = URL(string: "\(baseURL)/request-password-reset") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["email": email]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PasswordResetResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Response Types

struct LoginResponse: Decodable {
    let success: Bool
    let message: String?
    let redirectUrl: String
}

struct RegisterResponse: Decodable {
    let success: Bool
    let message: String
}

struct RoleVerificationResponse: Decodable {
    let valid: Bool
}

struct PasswordChangeResponse: Decodable {
    let success: Bool
    let message: String
}

struct PasswordResetResponse: Decodable {
    let success: Bool
    let message: String
}