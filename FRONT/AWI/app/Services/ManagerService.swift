import Foundation
import Combine
import Game

class ManagerService {
    private let baseURL = "http://localhost:3000"
    
    // MARK: - Mise en vente 
    
    func fetchCatalogue() -> AnyPublisher<CatalogueResponse, Error> {
        guard let url = URL(string: "\(baseURL)/catalogue") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CatalogueResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func toggleEnVente(_ game: Game) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/jeux/\(game.id)/toggle-vente") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["enVente": !game.enVente]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in return Void() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Payer vendeur 
    
    func fetchSellerSales(email: String) -> AnyPublisher<[SaleItem], Error> {
        guard let url = URL(string: "\(baseURL)/sellers-with-sales") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [SaleItem].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func paySeller(sellerId: String) -> AnyPublisher<PaySellerResponse, Error> {
        guard let url = URL(string: "\(baseURL)/pay-seller/\(sellerId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PaySellerResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Enregistrer achat 
    
    func registerPurchase(_ purchase: Purchase) -> AnyPublisher<PurchaseResponse, Error> {
        guard let url = URL(string: "\(baseURL)/register-purchase") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(purchase)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: PurchaseResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Modèles de données (A remplacer par ceux du Fichiers Models.swift)

// Modèles de mise-en-vente
struct CatalogueResponse: Decodable {
    let games: [Game]
}

// Modèles de payer-vendeur
struct SaleItem: Codable, Identifiable {
    let id: String
    let nom: String
    let ventesMontant: Double
    let nbVentes: Int
    let paye: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nom, ventesMontant, nbVentes, paye
    }
}

struct PaySellerResponse: Codable {
    let success: Bool
    let message: String
}

// Modèles d'enregistrer-achat
struct Purchase: Codable {
    let jeuId: String
    let acheteurNom: String
}

struct PurchaseResponse: Codable {
    let success: Bool
    let message: String
}