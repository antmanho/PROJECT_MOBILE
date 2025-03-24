import SwiftUI

/// Composant réutilisable pour afficher une carte d'information
struct CardView: View {
    /// Titre de la carte
    let title: String
    
    /// URL de l'image à afficher
    let imageUrl: String
    
    /// Détails textuels
    let details: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.headline)
            
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 150)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 150)
            }
            
            Text(details)
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 4)
        .padding(5)
    }
}

/// Prévisualisation pour Xcode
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            title: "Exemple de jeu",
            imageUrl: "",
            details: "N°article : 123\n24.99 €\nEst en vente : OUI"
        )
    }
}