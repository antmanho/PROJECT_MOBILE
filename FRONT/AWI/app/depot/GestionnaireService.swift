// Service du gestionnaire pour le depot de jeux

import Foundation
import Combine

class GestionnaireService {
    private let baseURL = "http://localhost:3000"
    
    func fetchAllSessions() -> AnyPublisher<[Session], Error> {
        let url = URL(string: "\(baseURL)/sessions")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Session].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchSessionInfo(_ sessionId: String) -> AnyPublisher<Session, Error> {
        let url = URL(string: "\(baseURL)/session/\(sessionId)")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Session.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func submitDeposit(
        sessionId: String,
        emailVendeur: String,
        nomJeu: String,
        prixUnit: Double,
        quantiteDeposee: Int,
        estEnVente: Bool,
        editeur: String,
        description: String,
        imageData: Data?
    ) -> AnyPublisher<DepositResponse, Error> {
        let url = URL(string: "\(baseURL)/depot")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text fields
        let textFields: [String: String] = [
            "num_session": sessionId,
            "email_vendeur": emailVendeur,
            "nom_jeu": nomJeu,
            "prix_unit": String(prixUnit),
            "quantite_deposee": String(quantiteDeposee),
            "est_en_vente": estEnVente ? "true" : "false",
            "editeur": editeur,
            "description": description
        ]
        
        for (key, value) in textFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Add image if available
        if let imageData = imageData {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: DepositResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}