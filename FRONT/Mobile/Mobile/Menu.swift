import SwiftUI

struct Menu: View {
    @State private var selectedView: String = "Retrait"
    @State private var X: String = "G"
    @State private var activeButton: String? = "Retrait"

    // Ajout pour retenir l'email du particulier
    @State private var retraitEmail: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // 1) Menu du haut (fixe)
                ZStack {
                    Color.blue.ignoresSafeArea(edges: .top)
                    Text("Boardland")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 1)
                }
                .frame(height: 50)

                // 2) Top Menu (si applicable)
                if !getTopMenu().isEmpty {
                    HStack {
                        ForEach(getTopMenu(), id: \.self) { item in
                            MenuButton(label: item, isActive: activeButton == item) {
                                activeButton = item
                                selectedView = item
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.blue)
                }
                
                // 3) Contenu central (zone de rendu)
                GeometryReader { geometry in
                    ZStack {
                        switch selectedView {
                        case "Accueil":
                            Accueil()
                        case "Dépôt":
                            DepotView()
                        case "Retrait":
                            RetraitView(onAfficherListe: { email in
                                self.retraitEmail = email
                                self.selectedView = "RetraitListe"
                            })
                        case "RetraitListe":
                            RetraitListeView(email: retraitEmail, onRetour: {
                                self.selectedView = "Retrait"
                            })
                        case "Payer":
                            Text("Payer View")
                        case "Achat":
                            Text("Achat View")
                        case "Bilan":
                            Text("Bilan View")
                        case "ConnexionView":
                            ConnexionView()
                        case "InscriptionView":
                            InscriptionView()
                        default:
                            Text("Sélectionnez une option")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }
                }


                // 4) Menu du bas (fixe)
                ZStack {
                    Color.blue.ignoresSafeArea(edges: .bottom)
                    HStack {
                        MenuButtonLarge(label: "Accueil", isActive: activeButton == "Accueil") {
                            activeButton = "Accueil"
                            selectedView = "Accueil"
                        }
                        
                        VStack {
                            if X == "0" {
                                MenuButtonLarge(label: "Se connecter", isActive: activeButton == "Se connecter", isSmall: true) {
                                    activeButton = "Se connecter"
                                    selectedView = "ConnexionView"
                                }
                                MenuButtonLarge(label: "S’inscrire", isActive: activeButton == "S’inscrire", isSmall: true) {
                                    activeButton = "S’inscrire"
                                    selectedView = "InscriptionView"
                                }
                            } else {
                                Text(getRoleText())
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.top, 10)
                                    .font(X == "G" ? .caption : .body)

                                Button("Déconnexion") {
                                    print("Déconnexion")
                                }
                                .buttonStyle(MenuButtonStyle())
                            }
                        }
                        .frame(maxWidth: .infinity)

                        if X == "A" || X == "G" {
                            MenuButtonLarge(label: "Mise en Vente", isActive: activeButton == "Mise en Vente") {
                                activeButton = "Mise en Vente"
                                selectedView = "Mise en Vente"
                            }
                        } else {
                            MenuButtonLarge(label: "Catalogue", isActive: activeButton == "Catalogue") {
                                activeButton = "Catalogue"
                                selectedView = "Catalogue"
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 3)
                    .padding(2)
                }
                .frame(height: 60)
    
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func getTopMenu() -> [String] {
        switch X {
        case "G":
            return ["Dépôt", "Retrait", "Payer", "Achat", "Bilan"]
        case "A":
            return ["Créer Session", "Modifier Session", "Gestion Utilisateur"]
        case "V":
            return ["Tableau de Bord"]
        case "0":
            return []
        default:
            return []
        }
    }

    private func getRoleText() -> String {
        switch X {
        case "G": return "GESTIONNAIRE"
        case "A": return "ADMIN"
        case "V": return "VENDEUR"
        case "0": return "INVITÉ"
        default: return ""
        }
    }
}

// MARK: - Boutons de menu
struct MenuButton: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            Text(label)
                .font(.system(size: 17))
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .background(isActive ? Color(white: 0.98) : Color.black)
                .foregroundColor(isActive ? .black : .white)
                .cornerRadius(10)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.spring(), value: isActive)
        }
    }
}

struct MenuButtonLarge: View {
    let label: String
    let isActive: Bool
    var isSmall: Bool = false // Ajout du paramètre pour modifier le padding
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            Text(label)
                .font(.system(size: 17))
                .padding(.vertical, isSmall ? 5 : 25) // Changement dynamique du padding
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .background(isActive ? Color(white: 0.98) : Color.black)
                .foregroundColor(isActive ? .black : .white)
                .cornerRadius(10)
                .scaleEffect(isActive ? 1.05 : 1.0)
                .animation(.spring(), value: isActive)
        }
    }
}

struct MenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Vues Exemple
struct AccueilView: View {
    var body: some View {
        Text("Accueil View")
            .font(.largeTitle)
            .foregroundColor(.blue)
        Image("mon-image")
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
    }
}


// MARK: - Preview
#Preview {
    Menu()
}
