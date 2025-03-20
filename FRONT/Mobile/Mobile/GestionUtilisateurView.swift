import SwiftUI

// Modèle de données pour un utilisateur (la propriété "nom" reste dans le modèle mais n'est plus affichée)
struct User: Identifiable {
    let id = UUID()
    var email: String
    var password: String
    var nom: String
    var telephone: String
    var adresse: String
    var role: String
}

// Enum pour le type de notification
enum NotificationType {
    case success
    case error
}

struct GestionUtilisateurView: View {
    // Variables d'état pour le champ de recherche et la notification
    @State private var searchText: String = ""
    @State private var showNotification: Bool = false
    @State private var notificationMessage: String = "Opération réussie"
    @State private var notificationType: NotificationType = .success
    
    // Liste des utilisateurs (exemple)
    @State private var users: [User] = [
        User(email: "test@example.com", password: "secret", nom: "Test", telephone: "1234567890", adresse: "123 Rue", role: "Admin"),
        User(email: "john@example.com", password: "john123", nom: "John", telephone: "0987654321", adresse: "456 Avenue", role: "User")
    ]
    
    // Largeurs fixes pour les colonnes "Mot de passe" et "Rôle"
    let passwordColumnWidth: CGFloat = 55
    let roleColumnWidth: CGFloat = 55
    
    var body: some View {
        VStack(spacing: 20) {
            // Titre
            Text("GESTION-UTILISATEUR")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)))
                .padding(.top, 20)
            
        
            // Notification (affichée si showNotification est vrai)
            if showNotification {
                HStack {
                    Text(notificationMessage)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: {
                        showNotification = false
                    }) {
                        Text("×")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                }
                .padding()
                .background(notificationType == .success ? Color.green : Color.red)
                .cornerRadius(5)
                .padding(.horizontal)
            }
            
            // En-tête du "tableau" (colonnes "Nom" et "Adresse" supprimées)
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
                    ForEach(users.indices, id: \.self) { index in
                        // Couleur d'arrière-plan alternée pour les lignes
                        let bgColor = index % 2 == 0 ?
                            Color(red: 244/255, green: 244/255, blue: 244/255) :
                            Color(red: 224/255, green: 224/255, blue: 224/255)
                        
                        HStack {
                            // Colonne Email
                            TextField("Email", text: Binding(
                                get: { users[index].email },
                                set: { newValue in
                                    users[index].email = newValue
                                    markAsModified(at: index)
                                }
                            ))
                            .frame(maxWidth: .infinity)
                            
                            // Colonne Mot de passe (SecureField pour masquer le texte)
                            SecureField("Mot de passe", text: Binding(
                                get: { users[index].password },
                                set: { newValue in
                                    users[index].password = newValue
                                    markAsModified(at: index)
                                }
                            ))
                            .frame(width: passwordColumnWidth)
                            
                            // Colonne Téléphone
                            TextField("Téléphone", text: Binding(
                                get: { users[index].telephone },
                                set: { newValue in
                                    users[index].telephone = newValue
                                    markAsModified(at: index)
                                }
                            ))
                            .frame(maxWidth: .infinity)
                            
                            // Colonne Rôle
                            TextField("Rôle", text: Binding(
                                get: { users[index].role },
                                set: { newValue in
                                    users[index].role = newValue
                                    markAsModified(at: index)
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
            
            // Bouton pour sauvegarder les modifications
            Button(action: {
                saveChanges()
            }) {
                Text("Sauvegarder toutes les modifications")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .background(Color.gray)
            .cornerRadius(4)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // Fonction appelée lorsque l'utilisateur modifie un champ (à compléter selon vos besoins)
    func markAsModified(at index: Int) {
        // Implémenter la logique pour marquer l'utilisateur modifié
    }
    
    // Fonction de sauvegarde (à compléter)
    func saveChanges() {
        // Implémenter la sauvegarde de toutes les modifications
    }
}

struct GestionUtilisateurView_Previews: PreviewProvider {
    static var previews: some View {
        GestionUtilisateurView()
    }
}
