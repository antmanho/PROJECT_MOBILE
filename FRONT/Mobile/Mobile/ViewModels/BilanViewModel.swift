import Foundation
import Combine

class BilanViewModel: ObservableObject {
    // Input fields
    @Published var bilanParticulier = false
    @Published var sessionParticuliere = false
    @Published var emailParticulier = ""
    @Published var numeroSession = ""
    @Published var chargesFixes = ""
    
    // Status indicators
    @Published var isLoading = false
    @Published var error: String? = nil
    
    // API service (could be further abstracted to a service layer)
    private let baseURL = BaseUrl.lien
    
    // Network request to fetch bilan data
    func fetchBilanData(completion: @escaping (BilanGraphData) -> Void) {
        isLoading = true
        error = nil
        
        // Parameter conversion
        let charges = chargesFixes.isEmpty ? "0" : chargesFixes
        let bilanPartStr = bilanParticulier ? "true" : "false"
        let sessionPartStr = sessionParticuliere ? "true" : "false"
        
        var components = URLComponents(string: "\(baseURL)/bilan-graphe")!
        components.queryItems = [
            URLQueryItem(name: "bilanParticulier", value: bilanPartStr),
            URLQueryItem(name: "sessionParticuliere", value: sessionPartStr),
            URLQueryItem(name: "emailParticulier", value: emailParticulier),
            URLQueryItem(name: "numeroSession", value: numeroSession),
            URLQueryItem(name: "chargesFixes", value: charges)
        ]
        
        guard let url = components.url else {
            self.error = "URL invalide"
            self.isLoading = false
            return
        }
        
        print("URL bilan: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = "Erreur lors du chargement du bilan: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.error = "Aucune donnée reçue"
                    return
                }
                
                do {
                    let bilanData = try JSONDecoder().decode(BilanGraphData.self, from: data)
                    completion(bilanData)
                } catch {
                    self?.error = "Erreur de décodage du bilan: \(error.localizedDescription)"
                    print("Détails de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    // Form validation
    var isFormValid: Bool {
        if bilanParticulier && emailParticulier.isEmpty {
            return false
        }
        
        if sessionParticuliere && numeroSession.isEmpty {
            return false
        }
        
        return true
    }
    
    // Reset form
    func resetForm() {
        bilanParticulier = false
        sessionParticuliere = false
        emailParticulier = ""
        numeroSession = ""
        chargesFixes = ""
        error = nil
    }
}