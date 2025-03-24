import Foundation
import Combine

/// ViewModel pour gérer la logique d'inscription
class InscriptionViewModel: ObservableObject {
    // MARK: - Propriétés publiées (observables)
    
    /// Données du formulaire
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    /// États d'interface
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var registrationSuccessful: Bool = false
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    // MARK: - Propriétés calculées
    
    /// Vérifie si le formulaire est valide pour soumission
    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
    
    // MARK: - Méthodes publiques
    
    /// Enregistre un nouvel utilisateur
    func register(onSuccess: @escaping (String) -> Void) {
        // Validation du formulaire
        guard isFormValid else {
            if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                errorMessage = "Veuillez remplir tous les champs"
            } else if password != confirmPassword {
                errorMessage = "Les mots de passe ne correspondent pas"
            }
            return
        }
        
        errorMessage = nil
        isLoading = true
        
        // Préparation de la requête
        guard let url = URL(string: "\(baseURL)/api/inscription") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "password": password,
            "confirmPassword": confirmPassword
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Exécution de la requête
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur : \(error.localizedDescription)"
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.errorMessage = "Réponse invalide du serveur"
                    return
                }
                
                if let message = json["message"] as? String {
                    print("Message serveur : \(message)")
                    self.registrationSuccessful = true
                    onSuccess(self.email)
                } else {
                    self.errorMessage = "Inscription échouée"
                }
            }
        }.resume()
    }
    
    /// Réinitialise le formulaire
    func resetForm() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
    }
}