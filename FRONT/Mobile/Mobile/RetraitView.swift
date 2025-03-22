import SwiftUI

struct RetraitView: View {
    @State private var emailParticulier: String = ""

    // Closure appelée lorsque l'utilisateur souhaite afficher la liste
    let onAfficherListe: (String) -> Void

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
                            Text("RETRAIT D'UN JEU")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Champ de saisie pour l'email
                            TextField("Email particulier", text: $emailParticulier)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.emailAddress)
                            
                            // Bouton qui appelle la closure avec l'email saisi
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
                        .frame(maxWidth: 300)
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

struct RetraitView_Previews: PreviewProvider {
    static var previews: some View {
        RetraitView(onAfficherListe: { _ in })
    }
}
