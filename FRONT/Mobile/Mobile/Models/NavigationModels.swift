import Foundation

/// Énumération des rôles utilisateur dans l'application
enum UserRole: String, Codable {
    case admin = "A"
    case gestionnaire = "G"
    case vendeur = "V"
    case invite = "0"
    
    /// Récupère le texte d'affichage du rôle
    var displayText: String {
        switch self {
        case .admin: return "ADMIN"
        case .gestionnaire: return "GESTIONNAIRE"
        case .vendeur: return "VENDEUR"
        case .invite: return "INVITÉ"
        }
    }
    
    /// Conversion depuis une chaîne API
    static func fromApiRole(_ apiRole: String) -> UserRole {
        switch apiRole.lowercased() {
        case "admin": return .admin
        case "gestionnaire": return .gestionnaire
        case "vendeur": return .vendeur
        default: return .invite
        }
    }
    
    /// Liste des éléments de menu pour chaque rôle
    func getMenuItems() -> [String] {
        switch self {
        case .gestionnaire:
            return ["Dépôt", "Retrait", "Payer", "Achat", "Bilan"]
        case .admin:
            return ["Session", "Utilisateurs", "Pré-Inscription", "Gestionnaire"]
        case .vendeur:
            return ["Tableau de Bord"]
        case .invite:
            return []
        }
    }
    
    /// Détermine si l'utilisateur peut accéder à la vue Mise en Vente
    var canAccessMiseEnVente: Bool {
        self == .admin || self == .gestionnaire
    }
}

/// Modèle représentant un élément de menu
struct MenuItem: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let viewName: String
    let isSmall: Bool
    
    init(label: String, viewName: String? = nil, isSmall: Bool = false) {
        self.label = label
        self.viewName = viewName ?? label
        self.isSmall = isSmall
    }
}