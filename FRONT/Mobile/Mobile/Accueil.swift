import SwiftUI

struct Accueil: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    // Title
                    // Title
                    Text("ACCUEIL")
                        .foregroundColor(.black)
                        .font(.title2)
                        .fontWeight(.bold) // Le texte est en gras
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.top, 2)

                    
                    // Image et description
                    VStack {
                        Text("Cette application permet de gérer des festivals de jeux de société : achat, vente, et bien plus !")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Image("mon-image")
                            .resizable()
                            .scaledToFit() // Conserve les proportions
                            .frame(width: UIScreen.main.bounds.width / 1.65)
                        
                        
                    }
                    
                    // Information Bubbles
                    VStack(alignment: .leading, spacing: 10) {
                        InfoBubble(text: "🎲 Découvrez un large catalogue de jeux de société disponibles lors des festivals !")
                        InfoBubble(text: "📦 Enregistrez et suivez les jeux déposés facilement avec des étiquettes uniques.")

                    }
                    .padding()
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
}

struct InfoBubble: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundColor(.black)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
            .multilineTextAlignment(.center)
    }
}

struct Accueil_Previews: PreviewProvider {
    static var previews: some View {
        Accueil()
    }
}

