import Foundation
import Combine

class ConnexionViewModel: ObservableObject {
    // User inputs
    @Published var email: String = ""
    @Published var password: String = ""
    
    // State indicators
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // API base URL
    private let baseURL = BaseUrl.lien
    
    // Form validation
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    // Clear form fields
    func clearFields() {
        email = ""
        password = ""
        errorMessage = nil
    }
    
    // Login method
    func login(completion: @escaping (String) -> Void) {
        // Validate form
        guard isFormValid else {
            errorMessage = "Veuillez remplir tous les champs"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Prepare login request
        guard let url = URL(string: "\(baseURL)/api/connexion") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Send login request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur : \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let success = json["success"] as? Bool, success == true else {
                    self.errorMessage = "Connexion échouée. Vérifiez vos identifiants."
                    self.isLoading = false
                    return
                }
                
                // If login successful, get user info
                self.fetchUserInfo(completion: completion)
            }
        }.resume()
    }
    
    // Get user info after successful login
    private func fetchUserInfo(completion: @escaping (String) -> Void) {
        guard let infoUrl = URL(string: "\(baseURL)/api/user-info") else {
            errorMessage = "URL user-info invalide"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: infoUrl) { [weak self] infoData, infoResponse, infoError in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let infoError = infoError {
                    self.errorMessage = "Erreur info: \(infoError.localizedDescription)"
                    return
                }
                
                guard let infoData = infoData,
                      let infoJson = try? JSONSerialization.jsonObject(with: infoData) as? [String: Any],
                      let role = infoJson["role"] as? String else {
                    self.errorMessage = "Impossible de récupérer le rôle."
                    return
                }
                
                completion(role)
            }
        }.resume()
    }
}