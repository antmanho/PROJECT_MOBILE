import Foundation
import Combine

class CheckEmailViewModel: ObservableObject {
    // Input values
    @Published var codeRecu: String = ""
    private let email: String
    
    // Output/state values
    @Published var isVerifying: Bool = false
    @Published var errorMessage: String? = nil
    
    // Network service could be injected for better testability
    private let baseURL = BaseUrl.lien
    
    init(email: String) {
        self.email = email
    }
    
    func verifyCode(completion: @escaping (String) -> Void) {
        // Validation
        guard !codeRecu.isEmpty else {
            errorMessage = "Veuillez entrer un code valide"
            return
        }
        
        isVerifying = true
        errorMessage = nil
        
        // API call to verify code
        guard let url = URL(string: "\(baseURL)/verification-email") else {
            errorMessage = "URL invalide"
            isVerifying = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bodyDict: [String: Any] = [
            "email": email,
            "code_recu": codeRecu
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.handleVerificationResponse(data: data, error: error) { success in
                    if success {
                        self.fetchUserRole(completion: completion)
                    } else {
                        self.isVerifying = false
                    }
                }
            }
        }.resume()
    }
    
    private func handleVerificationResponse(data: Data?, error: Error?, completion: @escaping (Bool) -> Void) {
        if let error = error {
            errorMessage = "Erreur: \(error.localizedDescription)"
            completion(false)
            return
        }
        
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            errorMessage = "Réponse invalide du serveur"
            completion(false)
            return
        }
        
        if let message = json["message"] as? String {
            print("Réponse verification-email: \(message)")
            completion(true)
        } else {
            errorMessage = "Code de vérification invalide"
            completion(false)
        }
    }
    
    private func fetchUserRole(completion: @escaping (String) -> Void) {
        guard let infoUrl = URL(string: "\(baseURL)/api/user-info") else {
            errorMessage = "URL user-info invalide"
            isVerifying = false
            return
        }
        
        URLSession.shared.dataTask(with: infoUrl) { [weak self] infoData, infoResponse, infoError in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isVerifying = false
                
                if let infoError = infoError {
                    self.errorMessage = "Erreur info: \(infoError.localizedDescription)"
                    return
                }
                
                guard let infoData = infoData,
                      let infoJson = try? JSONSerialization.jsonObject(with: infoData) as? [String: Any],
                      let role = infoJson["role"] as? String else {
                    self.errorMessage = "Impossible de récupérer le rôle"
                    return
                }
                
                completion(role)
            }
        }.resume()
    }
}