import SwiftUI

/// Vue principale du menu et de la navigation
struct Menu: View {
    /// ViewModel pour la gestion de l'état et de la logique
    @StateObject private var viewModel = MenuViewModel()
    
    var body: some View {
        ZStack {
            // Navigation et contenu principal
            NavigationStack {
                VStack(spacing: 0) {
                    // En-tête avec le titre de l'application
                    headerView
                    
                    // Menu du haut dynamique en fonction du rôle
                    topMenuView
                    
                    // Zone de contenu centrale
                    mainContentView
                }
                .navigationBarBackButtonHidden(true)
            }
            
            // Menu du bas (fixe en bas de l'écran)
            VStack {
                Spacer()
                bottomMenuView
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    /// En-tête avec le titre de l'application
    private var headerView: some View {
        ZStack {
            Color.blue.ignoresSafeArea(edges: .top)
            Text("Boardland")
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 1)
        }
        .frame(height: 50)
    }
    
    /// Menu du haut dynamique selon le rôle de l'utilisateur
    private var topMenuView: some View {
        Group {
            if !viewModel.topMenuItems.isEmpty {
                HStack {
                    ForEach(viewModel.topMenuItems, id: \.self) { item in
                        MenuButton(
                            label: item,
                            isActive: viewModel.activeButton == item,
                            isAdmin: viewModel.userRole == .admin
                        ) {
                            viewModel.navigateTo(view: item, button: item)
                        }
                    }
                }
                .padding(8)
                .background(Color.blue)
            }
        }
    }
    
    /// Zone de contenu principale
    private var mainContentView: some View {
        GeometryReader { geometry in
            ZStack {
                // Switch pour afficher la vue correspondante
                switch viewModel.selectedView {
                // Vues de l'administration
                case "ModificationSessionView":
                    ModificationSessionView(selectedView: $viewModel.selectedView)
                    
                // Vues communes
                case "Accueil":
                    Accueil()
                case "Catalogue":
                    CatalogueView(games: viewModel.catalogueGames, onGameSelected: { game in
                        viewModel.showGameDetails(gameId: game.id, fromView: "Catalogue")
                    })
                case "Mise en Vente":
                    MiseEnVenteView(onGameSelected: { game in
                        viewModel.showGameDetails(gameId: game.id, fromView: "Mise en Vente")
                    })
                case "DetailArticle":
                    if let id = viewModel.selectedGame {
                        DetailArticleView(gameId: id, onBack: {
                            viewModel.returnFromGameDetails()
                        })
                    } else {
                        Text("Aucun produit sélectionné")
                    }
                    
                // Vues d'authentification
                case "ConnexionView":
                    ConnexionView(
                        onMotDePasseOublie: {
                            viewModel.lastViewBeforeMotPasseOublie = "ConnexionView"
                            viewModel.selectedView = "MotPasseOublieView"
                        },
                        onInscription: {
                            viewModel.navigateTo(view: "InscriptionView", button: "S'inscrire")
                        },
                        onLoginSuccess: { role in
                            viewModel.handleLoginSuccess(role: role)
                        }
                    )
                case "InscriptionView":
                    InscriptionView(
                        onMotDePasseOublie: {
                            viewModel.lastViewBeforeMotPasseOublie = "InscriptionView"
                            viewModel.selectedView = "MotPasseOublieView"
                        },
                        onConnexion: {
                            viewModel.navigateTo(view: "ConnexionView", button: "Se connecter")
                        },
                        onCheckEmail: { email in
                            print("Inscription réussie pour l'email : \(email)")
                            viewModel.navigateTo(view: "CheckEmailView")
                        }
                    )
                case "CheckEmailView":
                    CheckEmailView(
                        email: viewModel.retraitEmail,
                        onRetour: {
                            viewModel.selectedView = "InscriptionView"
                        },
                        onInvité: {
                            viewModel.selectedView = "Menu"
                        },
                        onVerificationSuccess: { role in
                            viewModel.handleLoginSuccess(role: role)
                        }
                    )
                case "MotPasseOublieView":
                    MotPasseOublieView(
                        onRetourDynamic: {
                            viewModel.selectedView = viewModel.lastViewBeforeMotPasseOublie
                        },
                        onInscription: {
                            viewModel.navigateTo(view: "InscriptionView", button: "S'inscrire")
                        }
                    )
                    
                // Vues gestionnaire
                case "Dépôt":
                    DepotView()
                case "Pré-Inscription":
                    PreinscriptionView(selectedView: $viewModel.selectedView)
                case "Session":
                    SessionView(selectedView: $viewModel.selectedView)
                case "CreerSessionView":
                    CreerSessionView(onRetour: {
                        viewModel.selectedView = "Session"
                    })
                case "Utilisateurs":
                    GestionUtilisateurView()
                case "Achat":
                    EnregistrerAchatView(onConfirmerAchat: { idStock, quantite in
                        print("Achat confirmé : ID Stock \(idStock), Quantité \(quantite)")
                    })
                case "Gestionnaire":
                    GestionnaireView(selectedView: $viewModel.selectedView)
                case "Retrait":
                    RetraitView(onAfficherListe: { email in
                        viewModel.retraitEmail = email
                        viewModel.selectedView = "RetraitListe"
                    })
                case "RetraitListe":
                    RetraitListeView(email: viewModel.retraitEmail, onRetour: {
                        viewModel.selectedView = "Retrait"
                    }, onInvité: {
                        viewModel.selectedView = "Menu"
                    })
                case "Payer":
                    PayerVendeurView(onAfficherHistorique: { email in
                        viewModel.payerEmail = email
                        viewModel.selectedView = "HistoriqueAchats"
                    })
                case "HistoriqueAchats":
                    PayerVendeurListeView(email: viewModel.payerEmail, onRetour: {
                        viewModel.selectedView = "Payer"
                    })
                case "Bilan":
                    BilanView(onAfficherBilanGraphe: { data in
                        viewModel.bilanData = data
                        viewModel.selectedView = "BilanGraphe"
                    })
                case "BilanGraphe":
                    if let data = viewModel.bilanData {
                        BilanGrapheView(data: data, onRetour: {
                            viewModel.selectedView = "Bilan"
                        })
                    } else {
                        Text("Aucune donnée à afficher")
                    }
                    
                // Vue par défaut
                default:
                    Text("Sélectionnez une option")
                        .font(.title)
                        .foregroundColor(.black)
                }
            }
        }
    }
    
    /// Menu du bas fixe
    private var bottomMenuView: some View {
        ZStack {
            Color.blue.ignoresSafeArea(edges: .bottom)
            HStack {
                // Bouton Accueil
                MenuButtonLarge(label: "Accueil", isActive: viewModel.activeButton == "Accueil") {
                    viewModel.navigateTo(view: "Accueil", button: "Accueil")
                }
                
                // Section centrale (connexion/déconnexion)
                VStack {
                    if viewModel.isGuest {
                        // Boutons pour utilisateur non connecté
                        MenuButtonLarge(label: "Se connecter", isActive: viewModel.activeButton == "Se connecter", isSmall: true) {
                            viewModel.navigateTo(view: "ConnexionView", button: "Se connecter")
                        }
                        MenuButtonLarge(label: "S'inscrire", isActive: viewModel.activeButton == "S'inscrire", isSmall: true) {
                            viewModel.navigateTo(view: "InscriptionView", button: "S'inscrire")
                        }
                    } else {
                        // Affichage du rôle et bouton déconnexion
                        Text(viewModel.roleDisplayText)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                            .font(viewModel.roleFontSize)
                        
                        Button("Déconnexion") {
                            viewModel.logout()
                        }
                        .buttonStyle(DeconnexionButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Bouton Catalogue/Mise en vente
                if viewModel.canSeeMiseEnVente {
                    MenuButtonLarge(label: "Catalogue", isActive: viewModel.activeButton == "Mise en Vente") {
                        viewModel.navigateTo(view: "Mise en Vente", button: "Mise en Vente")
                    }
                } else {
                    MenuButtonLarge(label: "Catalogue", isActive: viewModel.activeButton == "Catalogue") {
                        viewModel.navigateTo(view: "Catalogue", button: "Catalogue")
                    }
                }
            }
            .padding(.bottom, 10)
            .padding(.top, 3)
            .padding(2)
        }
        .frame(height: 60)
    }
}

// MARK: - Composants d'interface réutilisables

/// Bouton de menu standard
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

/// Bouton large pour le menu du bas
struct MenuButtonLarge: View {
    let label: String
    let isActive: Bool
    var isSmall: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        } label: {
            Text(label)
                .font(.system(size: 17))
                .padding(.vertical, isSmall ? 5 : 25)
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

/// Style de bouton pour la déconnexion
struct DeconnexionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? Color(white: 0.98) : Color.black)
            .foregroundColor(configuration.isPressed ? .black : .white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 1.05 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

/// Prévisualisation pour Xcode
struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        Menu()
    }
}