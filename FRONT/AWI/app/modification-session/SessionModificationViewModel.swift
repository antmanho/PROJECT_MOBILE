import Foundation
import Combine

class SessionModificationViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var filteredSessions: [Session] = []
    @Published var searchText: String = ""
    
    @Published var showNotification = false
    @Published var notificationMessage = ""
    @Published var notificationType: NotificationType = .success
    
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    private let service = AdminService()
    
    enum NotificationType {
        case success, error
    }
    
    init() {
        // Setup search filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                if searchText.isEmpty {
                    self.filteredSessions = self.sessions
                } else {
                    self.filteredSessions = self.sessions.filter { session in
                        session.Nom_session.localizedCaseInsensitiveContains(searchText) ||
                        session.adresse_session.localizedCaseInsensitiveContains(searchText) ||
                        session.Description.localizedCaseInsensitiveContains(searchText)
                    }
                }
            }
            .store(in: &cancellables)
        
        getSessions()
    }
    
    func getSessions() {
        isLoading = true
        
        service.getSessions()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Error fetching sessions:", error)
                        self?.showNotificationWithMessage("Erreur lors de la récupération des sessions", type: .error)
                    }
                },
                receiveValue: { [weak self] sessions in
                    // Format dates
                    let formattedSessions = sessions.map { session in
                        var updatedSession = session
                        updatedSession.date_debut = self?.formatDate(session.date_debut) ?? ""
                        updatedSession.date_fin = self?.formatDate(session.date_fin) ?? ""
                        updatedSession.isModified = false
                        return updatedSession
                    }
                    
                    self?.sessions = formattedSessions
                    self?.filteredSessions = formattedSessions
                }
            )
            .store(in: &cancellables)
    }
    
    func formatDate(_ dateString: String) -> String {
        guard !dateString.isEmpty else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.string(from: date)
        }
        
        return dateString
    }
    
    func markAsModified(_ index: Int) {
        if index < filteredSessions.count {
            filteredSessions[index].isModified = true
            
            // Also update in main sessions array
            if let mainIndex = sessions.firstIndex(where: { $0.id_session == filteredSessions[index].id_session }) {
                sessions[mainIndex] = filteredSessions[index]
            }
        }
    }
    
    func saveChanges() {
        let modifiedSessions = sessions.filter { $0.isModified == true }
        
        if modifiedSessions.isEmpty {
            showNotificationWithMessage("Aucune modification à enregistrer", type: .error)
            return
        }
        
        isLoading = true
        
        service.saveSessions(modifiedSessions)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("Error saving sessions:", error)
                        self?.showNotificationWithMessage("Erreur lors de l'enregistrement des modifications", type: .error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.showNotificationWithMessage(response.message, type: .success)
                    
                    // Reload sessions after 4 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        self?.getSessions()
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func showNotificationWithMessage(_ message: String, type: NotificationType) {
        notificationMessage = message
        notificationType = type
        showNotification = true
        
        // Auto-hide notification after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.closeNotification()
        }
    }
    
    func closeNotification() {
        showNotification = false
    }
}