import SwiftUI

struct SessionView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image de fond avec opacité faible et dimensions contraintes
                Image("fond_button")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped() // pour couper l'excès d'image
                    .opacity(0.15)
                    .ignoresSafeArea()
                
                VStack {
                    // Titre "SESSION"
                    Text("SESSION")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 40)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        // Bouton "Creer Session" dans une bulle bleue
                        Button(action: {
                            // Action pour "Creer Session"
                        }) {
                            Text("Creer Session")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 20)
                        
                        // Bouton "Modifier Session" dans une bulle bleue
                        Button(action: {
                            // Action pour "Modifier Session"
                        }) {
                            Text("Modifier Session")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width) // Contraint la largeur du contenu
            }
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView()
    }
}
