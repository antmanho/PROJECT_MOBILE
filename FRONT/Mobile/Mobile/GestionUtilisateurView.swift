import SwiftUI
import UserNotifications
import Foundation

struct User: Identifiable, Codable {
    let id: Int // Correspond à id_users
    var email: String
    var password: String
    var nom: String
    var telephone: String
    var adresse: String
    var role: String

    enum CodingKeys: String, CodingKey {
        case id = "id_users"
        case email
        case password = "mdp"
        case nom
        case telephone
        case adresse
        case role
    }
}



struct GestionUtilisateurView: View {
    @State private var searchText: String = ""
    @State private var users: [User] = []
    
    // Largeurs fixes pour certaines colonnes
    let passwordColumnWidth: CGFloat = 120
    let roleColumnWidth: CGFloat = 70
    
    // Base URL de votre back
    let baseURL = BaseUrl.lien
    
    var filteredUsers: [User] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { $0.email.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Titre
            Text("GESTION-UTILISATEUR")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.black)
                .padding(.top, 20)
            
            // Barre de recherche
            TextField("Rechercher...", text: $searchText)
                .padding(8)
                .background(Color.white)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.black, lineWidth: 2)
                )
                .padding(.horizontal)
            
            // En-tête du tableau
            HStack {
                Text("Email")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                Text("Mot de passe")
                    .frame(width: passwordColumnWidth)
                    .foregroundColor(.white)
                Text("Téléphone")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                Text("Rôle")
                    .frame(width: roleColumnWidth)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.gray)
            
            // Corps du tableau dans un ScrollView
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredUsers.indices, id: \.self) { index in
                        let bgColor = index % 2 == 0 ?
                            Color(red: 244/255, green: 244/255, blue: 244/255) :
                            Color(red: 224/255, green: 224/255, blue: 224/255)
                        
                        HStack {
                            // Colonne Email
                            TextField("Email", text: Binding(
                                get: { filteredUsers[index].email },
                                set: { newValue in
                                    if let i = users.firstIndex(where: { $0.id == filteredUsers[index].id }) {
                                        users[i].email = newValue
                                    }
                                }
                            ))
                            .frame(maxWidth: .infinity)
                            
                            // Colonne Mot de passe (SecureField pour masquer le texte)
                            SecureField("Mot de passe", text: Binding(
                                get: { filteredUsers[index].password },
                                set: { newValue in
                                    if let i = users.firstIndex(where: { $0.id == filteredUsers[index].id }) {
                                        users[i].password = newValue
                                    }
                                }
                            ))
                            .frame(width: passwordColumnWidth)
                            
                            // Colonne Téléphone
                            TextField("Téléphone", text: Binding(
                                get: { filteredUsers[index].telephone },
                                set: { newValue in
                                    if let i = users.firstIndex(where: { $0.id == filteredUsers[index].id }) {
                                        users[i].telephone = newValue
                                    }
                                }
                            ))
                            .frame(maxWidth: .infinity)
                            
                            // Colonne Rôle
                            TextField("Rôle", text: Binding(
                                get: { filteredUsers[index].role },
                                set: { newValue in
                                    if let i = users.firstIndex(where: { $0.id == filteredUsers[index].id }) {
                                        users[i].role = newValue
                                    }
                                }
                            ))
                            .frame(width: roleColumnWidth)
                        }
                        .padding(8)
                        .background(bgColor)
                        .overlay(
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                }
            }
            
            // Bouton de sauvegarde
            Button(action: {
                saveChanges()
            }) {
                Text("Sauvegarder les modifications")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(Color.gray)
            .cornerRadius(4)
            .padding(.horizontal)
            
            Spacer()
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            fetchUsers()
            // Demande d'autorisation pour les notifications
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                // Gestion d'erreur si besoin
            }
        }
    }
    
    // Récupération des utilisateurs depuis le back
    func fetchUsers() {
        guard let url = URL(string: "\(baseURL)/api/users") else {
            print("URL invalide")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors de la récupération des utilisateurs: \(error)")
                return
            }
            guard let data = data else {
                print("Aucune donnée reçue")
                return
            }
            do {
                let decodedUsers = try JSONDecoder().decode([User].self, from: data)
                DispatchQueue.main.async {
                    self.users = decodedUsers
                }
            } catch {
                print("Erreur de décodage des utilisateurs: \(error)")
            }
        }.resume()
    }
    
    // Sauvegarde des modifications via la route PUT
    func saveChanges() {
        guard let url = URL(string: "\(baseURL)/api/users") else {
            print("URL invalide pour sauvegarde")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encodage de tous les utilisateurs modifiés
        do {
            let jsonData = try JSONEncoder().encode(users)
            request.httpBody = jsonData
        } catch {
            print("Erreur lors de l'encodage des utilisateurs: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur lors de la sauvegarde: \(error)")
                scheduleLocalNotification(title: "Erreur", message: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                scheduleLocalNotification(title: "Succès", message: "Utilisateurs mis à jour avec succès")
            }
        }.resume()
    }
    
    // Planification d'une notification locale
    private func scheduleLocalNotification(title: String, message: String) {
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
}

struct GestionUtilisateurView_Previews: PreviewProvider {
    static var previews: some View {
        GestionUtilisateurView()
    }
}

