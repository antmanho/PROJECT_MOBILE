import Foundation
import SwiftUI
import Combine
import UserNotifications
import PhotosUI

/// ViewModel pour gérer les dépôts de jeux
class DepotViewModel: ObservableObject {
    // MARK: - Propriétés publiées (observables)
    
    /// Données du formulaire
    @Published var emailVendeur: String = ""
    @Published var nomJeu: String = ""
    @Published var prixUnit: String = ""
    @Published var quantiteDeposee: String = ""
    @Published var editeur: String = ""
    @Published var description: String = ""
    @Published var estEnVente: Bool = false
    
    /// Gestion de la session
    @Published var sessions: [Session] = []
    @Published var selectedSession: Session? = nil
    
    /// Gestion de l'interface
    @Published var showOptionalFields: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    
    /// Gestion des images
    @Published var selectedImage: UIImage? = nil
    @Published var photosPickerItem: PhotosPickerItem? = nil {
        didSet {
            loadTransferable(from: photosPickerItem)
        }
    }
    
    /// URL de base pour les appels API
    private let baseURL = BaseUrl.lien
    
    /// Stockage des cancellables pour Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialisation
    
    init() {
        /// Observation du changement de sélection d'image
        $photosPickerItem
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.loadTransferable(from: self?.photosPickerItem)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Propriétés calculées
    
    /// Vérifie si le formulaire est valide pour soumission
    var isFormValid: Bool {
        !emailVendeur.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nomJeu.trimmingCharacters(in: .whitespaces).isEmpty &&
        !prixUnit.trimmingCharacters(in: .whitespaces).isEmpty &&
        !quantiteDeposee.trimmingCharacters(in: .whitespaces).isEmpty &&
        selectedSession != nil
    }
    
    // MARK: - Méthodes publiques
    
    /// Charge la liste des sessions depuis l'API
    func loadSessions() {
        guard let url = URL(string: "\(baseURL)/get_all_sessions") else {
            errorMessage = "URL sessions invalide"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Erreur lors du chargement des sessions: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Aucune donnée reçue pour les sessions"
                    return
                }
                
                do {
                    // Configuration du décodeur pour les dates
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)
                    
                    let sessionsArray = try decoder.decode([Session].self, from: data)
                    self?.sessions = sessionsArray
                } catch {
                    self?.errorMessage = "Erreur de décodage des sessions: \(error.localizedDescription)"
                    print("Détail de l'erreur: \(error)")
                }
            }
        }.resume()
    }
    
    /// Formate une date pour l'affichage
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: date)
    }
    
    /// Soumet le formulaire de dépôt
    func submitDepot() {
        // Validation du formulaire
        if !isFormValid {
            errorMessage = "Veuillez remplir tous les champs obligatoires."
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "\(baseURL)/depot") else {
            errorMessage = "URL invalide pour depot"
            scheduleLocalNotification(title: "Erreur", message: errorMessage)
            isLoading = false
            return
        }
        
        // Préparation de la requête multipart
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(boundary: boundary)
        
        // Envoi de la requête
        URLSession.shared.uploadTask(with: request, from: body) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Erreur lors de l'ajout: \(error.localizedDescription)"
                    self?.scheduleLocalNotification(title: "Erreur", message: self?.errorMessage ?? "")
                    return
                }
                
                guard let data = data,
                      let responseJSON = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let message = responseJSON["message"] as? String else {
                    self?.errorMessage = "Réponse invalide du serveur."
                    self?.scheduleLocalNotification(title: "Erreur", message: self?.errorMessage ?? "")
                    return
                }
                
                self?.isSuccess = true
                self?.scheduleLocalNotification(title: "Succès", message: message)
                self?.resetForm()
            }
        }.resume()
    }
    
    /// Réinitialise le formulaire après succès
    func resetForm() {
        emailVendeur = ""
        nomJeu = ""
        prixUnit = ""
        quantiteDeposee = ""
        editeur = ""
        description = ""
        selectedImage = nil
        photosPickerItem = nil
        estEnVente = false
        selectedSession = nil
        errorMessage = ""
    }
    
    /// Programme une notification locale
    func scheduleLocalNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Demande l'autorisation pour les notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    // MARK: - Méthodes privées
    
    /// Charge l'image sélectionnée dans le picker
    private func loadTransferable(from photosPickerItem: PhotosPickerItem?) {
        guard let photosPickerItem = photosPickerItem else { return }
        
        photosPickerItem.loadTransferable(type: Data.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self?.selectedImage = uiImage
                    }
                case .failure(let error):
                    self?.errorMessage = "Erreur lors du chargement de l'image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    /// Crée le corps de la requête multipart pour l'envoi du formulaire
    private func createMultipartBody(boundary: String) -> Data {
        var body = Data()
        
        func appendFormField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        // Ajout de tous les champs du formulaire
        appendFormField(name: "email_vendeur", value: emailVendeur)
        appendFormField(name: "nom_jeu", value: nomJeu)
        appendFormField(name: "prix_unit", value: prixUnit)
        appendFormField(name: "quantite_deposee", value: quantiteDeposee)
        appendFormField(name: "est_en_vente", value: "\(estEnVente ? 1 : 0)")
        appendFormField(name: "editeur", value: editeur)
        appendFormField(name: "description", value: description)
        
        if let session = selectedSession {
            appendFormField(name: "num_session", value: "\(session.id)")
        }
        
        // Ajout de l'image si présente
        if let image = selectedImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"depot.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}