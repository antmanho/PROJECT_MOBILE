import SwiftUI

// Le RetraitView reçoit une closure 'onAfficherListe' au lieu d'un NavigationLink
struct RetraitView: View {
    @State private var emailParticulier: String = ""

    // Cette closure est appelée quand on veut "naviguer" vers la liste
    let onAfficherListe: (String) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Image de fond occupant tout l'écran
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // ScrollView pour gérer le défilement
                ScrollView {
                    VStack {
                        Spacer(minLength: 40) // Espace en haut
                        
                        // ---------- FORMULAIRE ----------
                        VStack(spacing: 10) {
                            Text("RETRAIT D'UN JEU")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Champ pour l'email
                            TextField("Email particulier", text: $emailParticulier)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.emailAddress)
                            
                            // Au lieu de NavigationLink, on appelle la closure
                            Button {
                                onAfficherListe(emailParticulier)
                            } label: {
                                Text("Afficher Liste")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 300)  // Même largeur que dans DepotView
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        
                        Spacer(minLength: 60) // Espace en bas
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct RetraitView_Previews: PreviewProvider {
    static var previews: some View {
        // On fournit une closure "bouchon" (stub) qui ne fait rien
        RetraitView(onAfficherListe: { _ in
            // Ne rien faire dans la Preview
        })
    }
}
