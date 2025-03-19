import SwiftUI

struct Menu: View {
    @State private var selectedView: String = "Accueil"
    @State private var X: String = "A"
    @State private var activeTopButton: String? = nil
    @State private var activeBottomButton: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // 1) Menu du haut (fixe)
                ZStack {
                    Color.blue
                        .ignoresSafeArea(edges: .top)

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
                            MenuButton(label: item, isActive: activeTopButton == item) {
                                activeTopButton = item
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
                            Text("Retrait View")
                        case "Payer":
                            Text("Payer View")
                        case "Achat":
                            Text("Achat View")
                        case "Bilan":
                            Text("Bilan View")
                        default:
                            Text("Sélectionnez une option")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }

                // 4) Menu du bas (fixe)
                ZStack {
                    Color.blue.ignoresSafeArea(edges: .bottom)

                    HStack {
                        MenuButtonLarge(label: "Accueil", isActive: activeBottomButton == "Accueil") {
                            activeBottomButton = "Accueil"
                            selectedView = "Accueil"
                        }

                        VStack {
                            if X == "0" {
                                MenuButtonLarge(label: "Se connecter", isActive: activeBottomButton == "Se connecter") {
                                    activeBottomButton = "Se connecter"
                                }
                                MenuButtonLarge(label: "S’inscrire", isActive: activeBottomButton == "S’inscrire") {
                                    activeBottomButton = "S’inscrire"
                                }
                            } else {
                                Text(getRoleText())
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.top, 10)

                                Button("Déconnexion") {
                                    print("Déconnexion")
                                }
                                .buttonStyle(MenuButtonStyle())
                            }
                        }
                        .frame(maxWidth: .infinity)

                        if X == "A" || X == "G" {
                            MenuButtonLarge(label: "Mise en Vente", isActive: activeBottomButton == "Mise en Vente") {
                                activeBottomButton = "Mise en Vente"
                                selectedView = "Mise en Vente"
                            }
                        } else {
                            MenuButtonLarge(label: "Catalogue", isActive: activeBottomButton == "Catalogue") {
                                activeBottomButton = "Catalogue"
                                selectedView = "Catalogue"
                            }
                        }
                    }
                    .padding(.bottom, 18)
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
                .background(isActive ? Color(white: 0.9) : Color.black)
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
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            Text(label)
                .font(.system(size: 17))
                .padding(.vertical, 25)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .background(isActive ? Color(white: 0.9) : Color.black)
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

struct DepotView: View {
    var body: some View {
        Text("Dépôt View")
            .font(.largeTitle)
            .foregroundColor(.green)
    }
}

// MARK: - Preview
#Preview {
    Menu()
}
