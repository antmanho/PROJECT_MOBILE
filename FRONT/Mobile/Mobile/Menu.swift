import SwiftUI

struct Menu: View {
    @State private var selectedView: String = "ConnexionView"
    @State private var X: String = "A" // Simule le rôle Admin
    @State private var activeButton: String? = "Se connecter"

    // Ajout pour retenir l'email du particulier
    @State private var retraitEmail: String = ""

    // Ajout pour retenir l'email du vendeur (paiement)
    @State private var payerEmail: String = ""
    @State private var bilanData: BilanData? = nil

    // États pour la navigation interne
    @State private var selectedGame: Int? = nil
    @State private var catalogueGames: [Game] = []  // Chargez ces jeux depuis votre back

    @State private var lastViewBeforeMotPasseOublie: String = "ConnexionView"
    @State private var lastViewBeforeDetailArticle: String = "CatalogueView"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // 🔹 Menu du haut (fixe)
                ZStack {
                    Color.blue.ignoresSafeArea(edges: .top)
                    Text("Boardland")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 1)
                }
                .frame(height: 50)

                // 🔹 **Top Menu (ajout des nouvelles cases)**
                if !getTopMenu().isEmpty {
                    HStack {
                        ForEach(getTopMenu(), id: \.self) { item in
                            MenuButton(
                                label: item,
                                isActive: activeButton == item,
                                isAdmin: X == "A"
                            ) {
                                activeButton = item
                                selectedView = item
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.blue)
                }
                
                // 🔹 **Contenu central (zone de rendu)**
                GeometryReader { geometry in
                    ZStack {
                        switch selectedView {
                        case "ModificationSessionView":
                            ModificationSessionView(selectedView: $selectedView)

                        case "Accueil":
                            Accueil()
                        case "Catalogue":
                            CatalogueView(games: catalogueGames, onGameSelected: { game in
                                selectedGame = game.id
                                lastViewBeforeDetailArticle = "Catalogue"
                                selectedView = "DetailArticle"
                            })

                        case "Mise en Vente":
                            MiseEnVenteView(onGameSelected: { game in
                                selectedGame = game.id
                                lastViewBeforeDetailArticle = "Mise en Vente"
                                selectedView = "DetailArticle"
                            })



                        case "DetailArticle":
                            if let id = selectedGame {
                                DetailArticleView(gameId: id, onBack: {
                                    selectedView = lastViewBeforeDetailArticle
                                })
                            } else {
                                Text("Aucun produit sélectionné")
                            }
                        
                        case "ConnexionView":
                            ConnexionView(
                                onMotDePasseOublie: {
                                    lastViewBeforeMotPasseOublie = "ConnexionView"
                                    selectedView = "MotPasseOublieView"
                                },
                                onInscription: {
                                    selectedView = "InscriptionView"
                                    activeButton = "S’inscrire"
                                }
                            )

                        case "InscriptionView":
                            InscriptionView(
                                onMotDePasseOublie: {
                                    lastViewBeforeMotPasseOublie = "InscriptionView"
                                    selectedView = "MotPasseOublieView"
                                },
                                onConnexion: {
                                    selectedView = "ConnexionView"
                                    activeButton = "Se connecter"
                                },
                                onCheckEmail: {
                                    selectedView = "CheckEmailView"
                                    activeButton = "S’inscrire"
                                }
                            )

                        case "CheckEmailView":
                            CheckEmailView(
                                email: "exemple@mail.com",
                                onRetour: {
                                    selectedView = "InscriptionView"
                                },
                                onInvité: {
                                    selectedView = "Menu"
                                }
                            )

                        case "MotPasseOublieView":
                            MotPasseOublieView(
                                onRetourDynamic: {
                                    selectedView = lastViewBeforeMotPasseOublie
                                },
                                onInscription: {
                                    selectedView = "InscriptionView"
                                    activeButton = "S’inscrire"
                                }
                            )

                        case "Dépôt":
                            DepotView()

                        case "Pré-Inscription":
                            PreinscriptionView(selectedView: $selectedView)

                        case "Session":
                            SessionView(selectedView: $selectedView)

                        case "CreerSessionView":
                            CreerSessionView(onRetour: {
                                selectedView = "Session"
                            })

                        case "Utilisateurs":
                            GestionUtilisateurView()
                        case "Achat":
                            EnregistrerAchatView { idStock, quantite in
                                print("Achat confirmé : ID Stock \(idStock), Quantité \(quantite)")
                                // Tu peux aussi mettre ici une logique pour enregistrer dans la base ou autre
                            }

                        case "Gestionnaire":
                            GestionnaireView(selectedView: $selectedView)

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
                            PayerVendeurView(onAfficherHistorique: { email in
                                self.payerEmail = email
                                self.selectedView = "HistoriqueAchats"
                            })

                        case "HistoriqueAchats":
                            PayerVendeurListeView(email: payerEmail, onRetour: {
                                self.selectedView = "Payer"
                            })

                        case "Bilan":
                            BilanView(onAfficherBilanGraphe: { data in
                                bilanData = data
                                selectedView = "BilanGraphe"
                            })
                    
                        case "BilanGraphe":
                            if let data = bilanData {
                                BilanGrapheView(data: data, onRetour: {
                                    selectedView = "Bilan"
                                })
                            } else {
                                Text("Aucune donnée à afficher")
                            }

                        default:
                            Text("Sélectionnez une option")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }
                }

                // 🔹 **Menu du bas (fixe)**
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
                            MenuButtonLarge(label: "Catalogue", isActive: activeButton == "Mise en Vente") {
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
            return ["Session", "Utilisateurs", "Pré-Inscription", "Gestionnaire"]
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

// 🔹 **Prévisualisation**
struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}



// MARK: - Boutons de menu
struct MenuButton: View {
    let label: String
    let isActive: Bool
    let isAdmin: Bool
    let action: () -> Void

    private var isSmallButton: Bool {
        label == "Pré-Inscription" || label == "Gestionnaire"
    }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            Text(label)
                .font(.system(size: isSmallButton ? 11 : (isAdmin ? 13.5 : 17)))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, isSmallButton ? 5 : 8)
                .padding(.horizontal, 6)
                .frame(maxWidth: .infinity, minHeight: isAdmin ? 50 : 40)
                .background(isActive ? Color(white: 0.98) : Color.black)
                .foregroundColor(isActive ? .black : .white)
                .cornerRadius(10)
                .scaleEffect(isActive ? 1.05 : 1.0)
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
