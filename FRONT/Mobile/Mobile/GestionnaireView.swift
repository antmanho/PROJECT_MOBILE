import SwiftUI

// Style personnalisé pour ajouter un effet de grossissement lors de l'appui
struct ScalingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct GestionnaireView: View {
    // Binding pour mettre à jour la vue sélectionnée dans le menu parent
    @Binding var selectedView: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image de fond avec opacité faible et dimensions contraintes
                Image("fond_button")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .opacity(0.15)
                    .ignoresSafeArea()
                
                VStack {
                    // Titre "GESTIONNAIRE"
                    Text("GESTIONNAIRE")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 40)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Bouton "Dépôt"
                        Button(action: {
                            selectedView = "Dépôt"
                        }) {
                            Text("Dépôt")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ScalingButtonStyle())
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 20)
                        
                        // Bouton "Retrait"
                        Button(action: {
                            selectedView = "Retrait"
                        }) {
                            Text("Retrait")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ScalingButtonStyle())
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 20)
                        
                        // Bouton "Payer"
                        Button(action: {
                            selectedView = "Payer"
                        }) {
                            Text("Payer")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ScalingButtonStyle())
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 20)
                        
                        // Bouton "Achat"
                        Button(action: {
                            selectedView = "Achat"
                        }) {
                            Text("Achat")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ScalingButtonStyle())
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 20)
                        
                        // Bouton "Bilan"
                        Button(action: {
                            selectedView = "Bilan"
                        }) {
                            Text("Bilan")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ScalingButtonStyle())
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
        }
    }
}

struct GestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        // Pour l'aperçu, nous utilisons une binding constante.
        GestionnaireView(selectedView: .constant("GESTIONNAIRE"))
    }
}
