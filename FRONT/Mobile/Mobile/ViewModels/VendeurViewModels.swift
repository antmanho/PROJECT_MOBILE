import Foundation
import Combine

class VendeurViewModel: ObservableObject {
    // MARK: - Propriétés publiées
    @Published var games: [Game] = []
    @Published var soldGames: [SoldGame] = []
    @Published var emailConnecte: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    // MARK: - Propriétés pour le bilan
    
    @Published var sessionParticuliere: Bool = false
    @Published var numeroSession: String = ""    
    @Published var chargesFixes: String = ""
    
    // MARK: - Propriétés privées
    
    private let baseURL = BaseUrl.lien
    
    // MARK: - Initialisation
    
    init() {
        fetchCatalogue()
        fetchSoldGames()
    }
    
    // MARK: - Propriétés calculées
    
    var isChargesFixesValid: Bool {
        if let _ = Double(chargesFixes) {
            return true
        }
        return false
    }
    
    var isNumeroSessionValid: Bool {
        if sessionParticuliere {
            return !numeroSession.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }
    
    var isFormValid: Bool {
        isChargesFixesValid && isNumeroSessionValid
    }
    
    // MARK: - Méthodes publiques
    
    func fetchCatalogue() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/catalogue-vendeur") else {
            errorMessage = "URL invalide pour le catalogue vendeur"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors du chargement du catalogue: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue pour le catalogue"
                    return
                }
                
                do {
                    let catalogueResponse = try JSONDecoder().decode(CatalogueResponse2.self, from: data)
                    self.games = catalogueResponse.results
                    self.emailConnecte = catalogueResponse.email_connecte
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Erreur de décodage du catalogue: \(error.localizedDescription)"
                    print("Détail de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    func fetchSoldGames() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/api/vendus") else {
            errorMessage = "URL invalide pour les jeux vendus"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Erreur lors du chargement des jeux vendus: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Aucune donnée reçue pour les jeux vendus"
                    return
                }
                
                do {
                    let soldGames = try JSONDecoder().decode([SoldGame].self, from: data)
                    self.soldGames = soldGames
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Erreur de décodage des jeux vendus: \(error.localizedDescription)"
                    print("Détail de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    func createBilanData() -> BilanData {
        return BilanData(
            bilanParticulier: true, 
            sessionParticuliere: sessionParticuliere,
            emailParticulier: emailConnecte ?? "",
            numeroSession: numeroSession,
            chargesFixes: Double(chargesFixes) ?? 0
        )
    }
    
    func resetBilanForm() {
        sessionParticuliere = false
        numeroSession = ""
        chargesFixes = ""
    }
}