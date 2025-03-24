import Foundation
import SwiftUI

/// ViewModel pour gérer les fonctionnalités du menu gestionnaire
class GestionnaireViewModel: ObservableObject {
    /// Liste des options disponibles dans le menu
    @Published var options: [GestionnaireOption] = []
    
    /// Initialisation avec chargement des options
    init() {
        loadOptions()
    }
    
    /// Charge les options du menu
    private func loadOptions() {
        options = [
            GestionnaireOption(title: "Dépôt", viewName: "Dépôt", color: "blue"),
            GestionnaireOption(title: "Retrait", viewName: "Retrait", color: "blue"),
            GestionnaireOption(title: "Payer", viewName: "Payer", color: "blue"),
            GestionnaireOption(title: "Achat", viewName: "Achat", color: "blue"),
            GestionnaireOption(title: "Bilan", viewName: "Bilan", color: "blue")
        ]
    }
    
    /// Renvoie la couleur correspondant au nom de couleur
    func getColor(for colorName: String) -> Color {
        switch colorName.lowercased() {
        case "blue":
            return Color.blue
        case "green":
            return Color.green
        case "red":
            return Color.red
        default:
            return Color.blue
        }
    }
    
    /// Sélectionne une vue et notifie le parent
    func selectView(_ viewName: String, updateBinding: (String) -> Void) {
        updateBinding(viewName)
    }
}