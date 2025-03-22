import SwiftUI
import UserNotifications

/// Vue pour la gestion des utilisateurs
struct GestionUtilisateurView: View {
    /// ViewModel contenant la logique et les données
    @StateObject private var viewModel = GestionUtilisateurViewModel()
    
    /// Largeurs fixes pour certaines colonnes
    private let passwordColumnWidth: CGFloat = 120
    private let roleColumnWidth: CGFloat = 70
    
    var body: some View {
        VStack(spacing: 20) {
            // Titre
            headerView
            
            // Barre de recherche
            searchBarView
            
            // Messages de statut
            statusMessagesView
            
            // Tableau des utilisateurs
            usersTableView
            
            // Bouton de sauvegarde
            saveButtonView
            
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            viewModel.fetchUsers()
            viewModel.requestNotificationPermission()
        }
        .overlay(
            loadingOverlay
        )
    }
    
    /// En-tête avec titre
    private var headerView: some View {
        Text("GESTION-UTILISATEUR")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(Color.black)
            .padding(.top, 20)
    }
    
    /// Barre de recherche
    private var searchBarView: some View {
        TextField("Rechercher par email ou nom...", text: $viewModel.searchText)
            .padding(8)
            .background(Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.horizontal)
    }
    
    /// Messages d'erreur et de succès
    private var statusMessagesView: some View {
        VStack {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            if let successMessage = viewModel.successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding(.horizontal)
            }
        }
    }
    
    /// Tableau des utilisateurs
    private var usersTableView: some View {
        VStack(spacing: 0) {
            // En-tête du tableau
            tableHeaderView
            
            // Corps du tableau
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.filteredUsers.indices, id: \.self) { index in
                        let user = viewModel.filteredUsers[index]
                        let bgColor = index % 2 == 0 ?
                            Color(red: 244/255, green: 244/255, blue: 244/255) :
                            Color(red: 224/255, green: 224/255, blue: 224/255)
                        
                        userRowView(user: user, index: index, bgColor: bgColor)
                    }
                }
            }
        }
    }
    
    /// En-tête du tableau
    private var tableHeaderView: some View {
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
    }
    
    /// Ligne pour un utilisateur
    private func userRowView(user: User, index: Int, bgColor: Color) -> some View {
        HStack {
            // Colonne Email
            TextField("Email", text: Binding(
                get: { user.email },
                set: { newValue in viewModel.updateUser(id: user.id, field: "email", value: newValue) }
            ))
            .frame(maxWidth: .infinity)
            
            // Colonne Mot de passe
            SecureField("Mot de passe", text: Binding(
                get: { user.password },
                set: { newValue in viewModel.updateUser(id: user.id, field: "password", value: newValue) }
            ))
            .frame(width: passwordColumnWidth)
            
            // Colonne Téléphone
            TextField("Téléphone", text: Binding(
                get: { user.telephone },
                set: { newValue in viewModel.updateUser(id: user.id, field: "telephone", value: newValue) }
            ))
            .frame(maxWidth: .infinity)
            
            // Colonne Rôle
            TextField("Rôle", text: Binding(
                get: { user.role },
                set: { newValue in viewModel.updateUser(id: user.id, field: "role", value: newValue) }
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
    
    /// Bouton de sauvegarde
    private var saveButtonView: some View {
        Button(action: {
            viewModel.saveChanges()
        }) {
            Text("Sauvegarder les modifications")
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
        }
        .background(Color.blue)
        .cornerRadius(4)
        .padding(.horizontal)
        .disabled(viewModel.isLoading)
    }
    
    /// Overlay de chargement
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Chargement...")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                    .padding(20)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    /// Masque le clavier
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Prévisualisation
struct GestionUtilisateurView_Previews: PreviewProvider {
    static var previews: some View {
        GestionUtilisateurView()
    }
}