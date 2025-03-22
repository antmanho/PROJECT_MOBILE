import SwiftUI

/// Style personnalisé pour ajouter un effet de grossissement lors de l'appui
struct ScalingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

/// Vue principale du menu gestionnaire
struct GestionnaireView: View {
    /// ViewModel contenant la logique et les données
    @StateObject private var viewModel = GestionnaireViewModel()
    
    /// Binding pour mettre à jour la vue sélectionnée dans le menu parent
    @Binding var selectedView: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image de fond avec opacité faible
                backgroundImage(geometry: geometry)
                
                VStack {
                    // Titre du menu
                    titleView()
                    
                    Spacer()
                    
                    // Boutons d'action
                    buttonsListView()
                    
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
        }
    }
    
    /// Affiche l'image de fond
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        Image("fond_button")
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .opacity(0.15)
            .ignoresSafeArea()
    }
    
    /// Affiche le titre du menu
    private func titleView() -> some View {
        Text("GESTIONNAIRE")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.top, 40)
            .padding(.horizontal)
    }
    
    /// Affiche la liste des boutons du menu
    private func buttonsListView() -> some View {
        VStack(spacing: 20) {
            // Création dynamique des boutons à partir du ViewModel
            ForEach(viewModel.options) { option in
                Button(action: {
                    viewModel.selectView(option.viewName) { newView in
                        selectedView = newView
                    }
                }) {
                    Text(option.title)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ScalingButtonStyle())
                .background(
                    Capsule()
                        .fill(viewModel.getColor(for: option.color))
                )
                .padding(.horizontal, 20)
            }
        }
    }
}

/// Prévisualisation pour Xcode
struct GestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        GestionnaireView(selectedView: .constant("GESTIONNAIRE"))
    }
}