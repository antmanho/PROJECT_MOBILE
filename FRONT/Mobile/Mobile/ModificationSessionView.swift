import SwiftUI
import UserNotifications

enum NotificationType {
    case success
    case error
}

struct SessionMod: Identifiable, Codable {
    var id: Int // id_session
    var nom: String      // Nom_session
    var adresse: String  // adresse_session
    var dateDebut: Date  // date_debut
    var dateFin: Date    // date_fin
    var chargeTotale: Double? // Charge_totale, optionnel
    var fraisFixe: Double     // Frais_depot_fixe
    var fraisPourcent: Double // Frais_depot_percent
    var description: String   // Description

    enum CodingKeys: String, CodingKey {
        case id = "id_session"
        case nom = "Nom_session"
        case adresse = "adresse_session"
        case dateDebut = "date_debut"
        case dateFin = "date_fin"
        case chargeTotale = "Charge_totale"
        case fraisFixe = "Frais_depot_fixe"
        case fraisPourcent = "Frais_depot_percent"
        case description = "Description"
    }
}

struct ModificationSessionView: View {
    @Binding var selectedView: String
    
    @State private var sessions: [SessionMod] = []
    @State private var searchText = ""
    @State private var errorMessage: String = ""
    
    // Utilisation de la constante de base URL depuis Constants.swift
    let baseURL = BaseUrl.lien
    
    var filteredSessions: [SessionMod] {
        if searchText.isEmpty {
            return sessions
        } else {
            return sessions.filter { $0.nom.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // Binding helper pour un champ String
    func binding(for session: SessionMod, keyPath: WritableKeyPath<SessionMod, String>) -> Binding<String> {
        Binding<String>(
            get: { session[keyPath: keyPath] },
            set: { newValue in
                if let i = sessions.firstIndex(where: { $0.id == session.id }) {
                    sessions[i][keyPath: keyPath] = newValue
                }
            }
        )
    }
    
    var body: some View {
        VStack {
            // Bouton retour
            HStack {
                Button {
                    selectedView = "Session"
                } label: {
                    Image("retour")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(4)
                }
                Spacer()
            }
            
            Text("MODIFICATION-SESSION")
                .font(.title2)
                .bold()
                .padding(.top, 10)
            
            TextField("Rechercher...", text: $searchText)
                .padding(6)
                .background(Color.white)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal)
            
            // Message d'erreur inline en rouge
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            // Formulaire d'édition dans un ScrollView avec un padding en bas pour éviter le débordement
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(filteredSessions, id: \.id) { session in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Nom", text: binding(for: session, keyPath: \.nom))
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            
                            Group {
                                HStack(spacing: 6) {
                                    Text("Adresse:")
                                        .bold()
                                    TextField("Adresse", text: binding(for: session, keyPath: \.adresse))
                                }
                                
                                HStack(spacing: 6) {
                                    Text("Date début:")
                                        .bold()
                                    DatePicker("", selection: Binding(
                                        get: { session.dateDebut },
                                        set: { newDate in
                                            if let i = sessions.firstIndex(where: { $0.id == session.id }) {
                                                sessions[i].dateDebut = newDate
                                            }
                                        }
                                    ), displayedComponents: .date)
                                    .labelsHidden()
                                }
                                
                                HStack(spacing: 6) {
                                    Text("Date fin:")
                                        .bold()
                                    DatePicker("", selection: Binding(
                                        get: { session.dateFin },
                                        set: { newDate in
                                            if let i = sessions.firstIndex(where: { $0.id == session.id }) {
                                                sessions[i].dateFin = newDate
                                            }
                                        }
                                    ), displayedComponents: .date)
                                    .labelsHidden()
                                }
                                
                                HStack(spacing: 6) {
                                    Text("Charge totale:")
                                        .bold()
                                    TextField("Charge totale", value: Binding(
                                        get: { session.chargeTotale },
                                        set: { newValue in
                                            if let i = sessions.firstIndex(where: { $0.id == session.id }) {
                                                sessions[i].chargeTotale = newValue
                                            }
                                        }
                                    ), formatter: Self.decimalFormatter)
                                    .keyboardType(.decimalPad)
                                }
                                
                                HStack(spacing: 6) {
                                    Text("Frais dépôt fixe:")
                                        .bold()
                                    TextField("Frais fixe", value: Binding(
                                        get: { session.fraisFixe },
                                        set: { newValue in
                                            if let i = sessions.firstIndex(where: { $0.id == session.id }) {
                                                sessions[i].fraisFixe = newValue
                                            }
                                        }
                                    ), formatter: Self.decimalFormatter)
                                    .keyboardType(.decimalPad)
                                }
                                
                                HStack(spacing: 6) {
                                    Text("Frais dépôt %:")
                                        .bold()
                                    TextField("Frais %", value: Binding(
                                        get: { session.fraisPourcent },
                                        set: { newValue in
                                            if let i = sessions.firstIndex(where: { $0.id == session.id }) {
                                                sessions[i].fraisPourcent = newValue
                                            }
                                        }
                                    ), formatter: Self.decimalFormatter)
                                    .keyboardType(.decimalPad)
                                }
                                
                                HStack(alignment: .top, spacing: 6) {
                                    Text("Description:")
                                        .bold()
                                    TextEditor(text: binding(for: session, keyPath: \.description))
                                        .frame(height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color.gray.opacity(0.4))
                                        )
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal, 8)
                        .shadow(radius: 1)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.bottom, 20)  // Pour éviter que le bouton ne déborde sur le menu du bas
            
            // Bouton de sauvegarde
            Button(action: {
                errorMessage = ""
                // Validation des champs obligatoires pour chaque session (Nom et Adresse)
                for session in sessions {
                    if session.nom.trimmingCharacters(in: .whitespaces).isEmpty ||
                        session.adresse.trimmingCharacters(in: .whitespaces).isEmpty {
                        errorMessage = "Tous les champs obligatoires (Nom, Adresse) doivent être remplis."
                        scheduleNotification(title: "Erreur", message: errorMessage)
                        return
                    }
                }
                saveChanges()
            }) {
                Text("Sauvegarder les modifications")
                    .foregroundColor(.white)
                    .padding(10)
                    .frame(maxWidth: .infinity)
            }
            .background(Color.gray)
            .cornerRadius(6)
            .padding(.horizontal)
            .padding(.bottom, 15)
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            fetchSessions()
        }
    }
    
    // Formatter pour les nombres décimaux
    static var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // Récupération des sessions depuis le backend avec une stratégie de décodage pour les dates
    func fetchSessions() {
        guard let url = URL(string: "\(baseURL)/api/sessions") else {
            errorMessage = "URL invalide pour sessions"
            scheduleNotification(title: "Erreur", message: errorMessage)
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur lors du chargement des sessions: \(error)"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "Aucune donnée reçue pour les sessions"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            
            // Affichage du JSON brut pour vérifier le format
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON reçu: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateStr = try container.decode(String.self)
                    if let date = isoFormatter.date(from: dateStr) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
                }
                
                let decodedSessions = try decoder.decode([SessionMod].self, from: data)
                DispatchQueue.main.async {
                    self.sessions = decodedSessions
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Erreur de décodage des sessions: \(error)"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
            }
        }.resume()
    }
    
    // Sauvegarde des modifications via une requête PUT
    func saveChanges() {
        guard let url = URL(string: "\(baseURL)/api/sessions") else {
            errorMessage = "URL invalide pour sauvegarde"
            scheduleNotification(title: "Erreur", message: errorMessage)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(sessions)
            request.httpBody = jsonData
        } catch {
            errorMessage = "Erreur lors de l'encodage des sessions: \(error)"
            scheduleNotification(title: "Erreur", message: errorMessage)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Erreur: \(error.localizedDescription)"
                    scheduleNotification(title: "Erreur", message: errorMessage)
                }
                return
            }
            DispatchQueue.main.async {
                scheduleNotification(title: "Succès", message: "Sessions mises à jour avec succès")
                errorMessage = ""
                // Optionnel : recharger les sessions si besoin
                fetchSessions()
            }
        }.resume()
    }
    
    // Déclenche une notification locale
    private func scheduleNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

struct ModificationSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ModificationSessionView(selectedView: .constant("Session"))
    }
}
