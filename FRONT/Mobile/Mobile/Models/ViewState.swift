import Foundation

/// Énumération représentant les différentes vues de l'application
enum ViewState: String, Equatable {
    // Vues communes
    case accueil = "Accueil"
    case catalogue = "Catalogue"
    case detailArticle = "DetailArticle"
    case miseEnVente = "Mise en Vente"
    
    // Authentification
    case connexion = "ConnexionView"
    case inscription = "InscriptionView"
    case checkEmail = "CheckEmailView"
    case motPasseOublie = "MotPasseOublieView"
    
    // Vues gestionnaire
    case depot = "Dépôt"
    case retrait = "Retrait"
    case retraitListe = "RetraitListe"
    case payer = "Payer"
    case achat = "Achat"
    case historiqueAchats = "HistoriqueAchats"
    case bilan = "Bilan"
    case bilanGraphe = "BilanGraphe"
    
    // Vues admin
    case session = "Session"
    case creerSession = "CreerSessionView"
    case modifierSession = "ModificationSessionView"
    case utilisateurs = "Utilisateurs"
    case preInscription = "Pré-Inscription"
    case gestionnaire = "Gestionnaire"
    
    // Vues vendeur
    case tableauBord = "Tableau de Bord"
    
    // Vue par défaut
    case undefined = ""
    
    /// Détermine si la vue est accessible à un rôle spécifique
    func isAccessibleTo(role: UserRole) -> Bool {
        switch self {
        case .accueil, .catalogue, .detailArticle:
            return true // Accessible à tous
            
        case .connexion, .inscription, .checkEmail, .motPasseOublie:
            return role == .invite // Accessible aux invités
            
        case .miseEnVente:
            return role == .admin || role == .gestionnaire
            
        case .depot, .retrait, .retraitListe, .payer, .achat, .historiqueAchats, .bilan, .bilanGraphe:
            return role == .gestionnaire
            
        case .session, .creerSession, .modifierSession, .utilisateurs, .preInscription, .gestionnaire:
            return role == .admin
            
        case .tableauBord:
            return role == .vendeur
            
        case .undefined:
            return false
        }
    }
    
    /// Convertit une chaîne en ViewState
    static func fromString(_ viewName: String) -> ViewState {
        return ViewState(rawValue: viewName) ?? .undefined
    }
}