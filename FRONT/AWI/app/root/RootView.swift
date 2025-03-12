import SwiftUI

struct RootView: View {
    @StateObject private var userState = UserStateModel()
    @State private var selectedMenuItem: String = "acceuil"
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top navbar
                topNavbar
                    .frame(height: geometry.size.height * 0.13)
                
                // Content area with sidebar
                HStack(spacing: 0) {
                    // Sidebar
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            // General section - available to all
                            sidebarSection(
                                title: "GENERAL",
                                items: generalMenuItems
                            )
                            
                            // Admin section - visible to admins
                            if userState.role == "admin" {
                                sidebarSection(
                                    title: "ADMIN",
                                    items: adminMenuItems
                                )
                            }
                            
                            // Manager section - visible to managers
                            if userState.role == "gestionnaire" {
                                sidebarSection(
                                    title: "GESTIONNAIRE",
                                    items: gestionnaireMenuItems
                                )
                            }
                            
                            // Seller section - visible to sellers
                            if userState.role == "vendeur" {
                                sidebarSection(
                                    title: "VENDEUR",
                                    items: vendeurMenuItems
                                )
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(width: geometry.size.width * 0.25)
                    .background(Color(.systemGray6))
                    
                    // Main content area
                    ZStack {
                        contentView(for: selectedMenuItem)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .environmentObject(userState)
    }
    
    // MARK: - Subviews
    
    private var topNavbar: some View {
        ZStack {
            
            
            HStack {
                // Logo
                Image("logo") // Replace with your actual logo
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .padding(.leading, 20)
                
                // Title
                Text("Boardland")
                    .font(.custom("Bangers", size: 48, relativeTo: .largeTitle))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                
                // Login/Logout buttons
                VStack(alignment: .trailing, spacing: 5) {
                    // User email or "NOT CONNECTED"
                    Text(userState.isAuthenticated ? userState.emailConnecte : "NON CONNECTE")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    HStack {
                        if !userState.isAuthenticated {
                            Button(action: {
                                selectedMenuItem = "connexion"
                            }) {
                                Text("Se connecter")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                            
                            Button(action: {
                                selectedMenuItem = "inscription"
                            }) {
                                Text("S'inscrire")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        } else {
                            Button(action: {
                                userState.deconnexion()
                            }) {
                                Text("Déconnexion")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
                .padding(.trailing, 20)
            }
        }
    }
    
    private func sidebarSection(title: String, items: [MenuItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            ForEach(items) { item in
                Button(action: {
                    selectedMenuItem = item.id
                }) {
                    HStack {
                        if let systemImage = item.systemImage {
                            Image(systemName: systemImage)
                                .foregroundColor(selectedMenuItem == item.id ? .blue : .primary)
                        }
                        
                        Text(item.title)
                            .foregroundColor(selectedMenuItem == item.id ? .blue : .primary)
                    }
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(SidebarButtonStyle())
            }
            
            Divider()
                .padding(.vertical, 5)
        }
    }
    
    // MARK: - Helper methods
    
    // Returns the appropriate view for the selected menu item
    private func contentView(for menuItem: String) -> some View {
        switch menuItem {
        case "acceuil":
            return AnyView(AccueilView())
        case "catalogue":
            return AnyView(CatalogueView())
        case "contact":
            return AnyView(ContactView())
        case "connexion":
            return AnyView(LoginView())
//        case "inscription":
//            return AnyView(SignUpView())
//        case "creer-session":
//            return AnyView(CreateSessionView())
//        case "modification-session":
//            return AnyView(ModificationSessionView())
//        case "gestion-utilisateur":
//            return AnyView(GestionUtilisateurView())
//        case "preinscription":
//            return AnyView(PreinscriptionView())
//        case "depot":
//            return AnyView(DepotView())
//        case "retrait":
//            return AnyView(RetraitView())
//        case "mise_en_vente":
//            return AnyView(MiseEnVenteView())
//        case "enregistrer_achat":
//            return AnyView(EnregistrerAchatView())
//        case "check_achat":
//            return AnyView(PayerVendeurView())
//        case "bilan":
//            return AnyView(BilanView())
//        case "vendeur":
//            return AnyView(VendeurDashboardView())
        default:
            return AnyView(Text("Page non trouvée").font(.largeTitle))
        }
    }
    
    // Menu items definitions
    
    private var generalMenuItems: [MenuItem] {
        [
            MenuItem(id: "acceuil", title: "Accueil", systemImage: "house"),
            MenuItem(id: "catalogue", title: "Catalogue", systemImage: "books.vertical"),
            MenuItem(id: "contact", title: "Contact", systemImage: "envelope")
        ]
    }
    
    private var adminMenuItems: [MenuItem] {
        [
            MenuItem(id: "creer-session", title: "Creer Session", systemImage: "plus.circle"),
            MenuItem(id: "modification-session", title: "Modifier Session", systemImage: "pencil"),
            MenuItem(id: "gestion-utilisateur", title: "Gestion Utilisateur", systemImage: "person.2"),
            MenuItem(id: "preinscription", title: "Pré-inscription", systemImage: "person.badge.plus")
        ]
    }
    
    private var gestionnaireMenuItems: [MenuItem] {
        [
            MenuItem(id: "depot", title: "Dépôt", systemImage: "arrow.down.doc"),
            MenuItem(id: "retrait", title: "Retrait", systemImage: "arrow.up.doc"),
            MenuItem(id: "mise_en_vente", title: "Mise en vente", systemImage: "tag"),
            MenuItem(id: "enregistrer_achat", title: "Enregistrer Achat", systemImage: "cart.badge.plus"),
            MenuItem(id: "check_achat", title: "Payer Vendeur", systemImage: "creditcard"),
            MenuItem(id: "bilan", title: "Bilan", systemImage: "chart.bar")
        ]
    }
    
    private var vendeurMenuItems: [MenuItem] {
        [
            MenuItem(id: "vendeur", title: "TABLEAU DE BORD", systemImage: "gauge")
        ]
    }
}

// MARK: - Supporting structures

struct MenuItem: Identifiable {
    let id: String
    let title: String
    let systemImage: String?
}

struct SidebarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// Placeholder views
//struct AccueilView: View {
//    var body: some View { Text("Page d'accueil").font(.largeTitle) }
//}

//struct ModificationSessionView: View {
//    var body: some View { Text("Modification de session").font(.largeTitle) }
//}

//struct GestionUtilisateurView: View {
//    var body: some View { Text("Gestion des utilisateurs").font(.largeTitle) }
//}

//struct PreinscriptionView: View {
//    var body: some View { Text("Pré-inscription").font(.largeTitle) }
//}

//struct DepotView: View {
//    var body: some View { Text("Dépôt").font(.largeTitle) }
//}

//struct RetraitView: View {
//    var body: some View { Text("Retrait").font(.largeTitle) }
//}

//struct MiseEnVenteView: View {
//   var body: some View { Text("Mise en vente").font(.largeTitle) }
//}

//struct EnregistrerAchatView: View {
//    var body: some View { Text("Enregistrer achat").font(.largeTitle) }
//}

//struct PayerVendeurView: View {
//    var body: some View { Text("Payer vendeur").font(.largeTitle) }
//}

//struct BilanView: View {
//    var body: some View { Text("Bilan").font(.largeTitle) }
//}

//struct VendeurDashboardView: View {
    //var body: some View { Text("Tableau de bord vendeur").font(.largeTitle) }
//}
