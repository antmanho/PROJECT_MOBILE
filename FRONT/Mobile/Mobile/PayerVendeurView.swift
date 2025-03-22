import SwiftUI

struct PayerVendeurView: View {
    @State private var emailVendeur: String = ""
    
    // Cette closure sera appelée pour naviguer vers PayerVendeurListeView avec l'email en paramètre.
    let onAfficherHistorique: (String) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                ScrollView {
                    VStack {
                        Spacer(minLength: 40)
                        
                        VStack(spacing: 10) {
                            Text("PAYER VENDEUR")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Champ email vendeur
                            TextField("Email du vendeur", text: $emailVendeur)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.emailAddress)
                            
                            // Bouton "Voir Historique des achats"
                            Button {
                                onAfficherHistorique(emailVendeur)
                            } label: {
                                Text("Voir Historique des achats")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .font(.system(size: 20))
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.white.opacity(0.97))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 3)
                        )
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
    }
}

struct PayerVendeurView_Previews: PreviewProvider {
    static var previews: some View {
        PayerVendeurView { email in
            print("Afficher l'historique pour : \(email)")
        }
    }
}
