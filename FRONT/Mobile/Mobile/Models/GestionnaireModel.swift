import Foundation

/// Modèle représentant une option du menu gestionnaire
struct GestionnaireOption: Identifiable {
    /// Identifiant unique de l'option
    let id = UUID()
    
    /// Titre affiché sur le bouton
    let title: String
    
    /// Nom de la vue à afficher lors de la sélection
    let viewName: String
    
    /// Couleur du bouton (optionnelle)
    let color: String
}