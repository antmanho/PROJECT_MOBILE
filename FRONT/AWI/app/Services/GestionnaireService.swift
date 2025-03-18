import Foundation
import Combine
import Game

class GestionnaireService {
    private let baseURL = "http://localhost:3000"
    
    // MARK: - Dépôt (dépôt)
    
    func fetchAllSessions() -> AnyPublisher<[Session], Error> {
        guard let url = URL(string: "\(baseURL)/sessions") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Session].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchSessionInfo(sessionId: String) -> AnyPublisher<SessionInfo, Error> {
        guard let url = URL(string: "\(baseURL)/sessions/\(sessionId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: SessionInfo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func submitDeposit(sessionId: String, vendeurNom: String, vendeurEmail: String, vendeurTelephone: String,
                      jeux: [JeuDepot]) -> AnyPublisher<DepositResponse, Error> {
        guard let url = URL(string: "\(baseURL)/deposit") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let deposit = Deposit(
            sessionId: sessionId,
            vendeurNom: vendeurNom,
            vendeurEmail: vendeurEmail,
            vendeurTelephone: vendeurTelephone,
            jeux: jeux
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(deposit)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: DepositResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Retrait (retrait-liste)
    
    func fetchJeux(email: String) -> AnyPublisher<[Game], Error> {
        guard let url = URL(string: "\(baseURL)/jeux-a-retirer?email=\(email)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Game].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func retirerJeux(jeuxIds: [String], vendeurNom: String) -> AnyPublisher<RetraitResponse, Error> {
        guard let url = URL(string: "\(baseURL)/retirer-jeux") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = RetraitRequest(jeuxIds: jeuxIds, vendeurNom: vendeurNom)
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: RetraitResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Modèles de dépôt ( A remplacer par ceux du Fichiers Models.swift)

struct Session: Codable, Identifiable {
    let id: String
    let nom: String
    let date: String
    let statut: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nom, date, statut
    }
}

struct SessionInfo: Codable {
    let id: String
    let nom: String
    let date: String
    let statut: String
    let emplacements: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nom, date, statut, emplacements
    }
}

struct Deposit: Codable {
    let sessionId: String
    let vendeurNom: String
    let vendeurEmail: String
    let vendeurTelephone: String
    let jeux: [JeuDepot]
}

struct JeuDepot: Codable {
    let nom: String
    let type: String
    let editeur: String
    let prix: Double
}

struct DepositResponse: Codable {
    let success: Bool
    let message: String
}

// MARK: - Modèles de retrait

struct RetraitRequest: Codable {
    let jeuxIds: [String]
    let vendeurNom: String
}

struct RetraitResponse: Codable {
    let success: Bool
    let message: String
}