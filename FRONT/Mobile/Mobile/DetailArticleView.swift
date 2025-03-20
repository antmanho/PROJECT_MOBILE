import SwiftUI

struct DetailArticleView: View {
    let game: Game
    // Closure appelée quand on appuie sur le bouton de retour
    var onBack: (() -> Void)?
    
    // Base URL pour charger l'image
    let baseImageURL = "http://localhost:3000"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Bouton retour en haut à gauche
                HStack {
                    Button(action: {
                        onBack?()
                    }) {
                        Image("retour") // Assurez-vous d'avoir l'image "retour" dans vos assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Titre centré
                Text("DETAIL DU PRODUIT")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)))
                    .padding(.top, 10)
                
                // Conteneur principal pour le produit
                HStack(alignment: .top, spacing: 20) {
                    // Zone image (similaire à .product-image)
                    if let url = URL(string: baseImageURL + game.photoPath) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            } else if phase.error != nil {
                                Color.red
                                    .overlay(Text("Erreur").foregroundColor(.white))
                            } else {
                                Color.gray
                            }
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.4)
                        .padding(.trailing, 20)
                    } else {
                        Color.gray
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.4)
                    }
                    
                    // Zone d'informations (similaire à .product-info)
                    VStack(alignment: .leading, spacing: 10) {
                        Text(game.nomJeu)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("N°article: \(game.id)")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "Prix: %.2f €", game.prixUnit))
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                        
                        if let editeur = game.editeur, !editeur.isEmpty {
                            Text("Éditeur: \(editeur)")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                        }
                        
                        if let description = game.description, !description.isEmpty {
                            Text("Description: \(description)")
                                .font(.system(size: 18))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(20)
                
                Spacer()
            }
        }
    }
}

struct DetailArticleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            // Exemple de données pour l'aperçu
            let dummyGame = Game(
                id: 1,
                nomJeu: "Exemple de Jeu",
                prixUnit: 29.99,
                photoPath: "/images/game1.jpg",
                fraisDepotFixe: 5,
                fraisDepotPercent: 10,
                prixFinal: 29.99,
                estEnVente: true,
                editeur: "Editeur Exemple",
                description: "Ceci est une description détaillée du jeu exemple."
            )
            DetailArticleView(game: dummyGame, onBack: {
                // Action de retour pour l'aperçu
            })
        }
    }
}

