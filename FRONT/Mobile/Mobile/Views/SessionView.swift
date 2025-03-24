import SwiftUI

struct SessionView: View {
    @Binding var selectedView: String
    @State private var isCreerSessionActive = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 🔹 Image de fond
                    Image("fond_button")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .opacity(0.15)
                        .ignoresSafeArea()

                    VStack {
                        // 🔹 Titre
                        Text("SESSION")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 40)

                        Spacer()

                        VStack(spacing: 20) {
                            // 🔹 Bouton "Créer Session"
                            Button(action: {
                                selectedView = "CreerSessionView"
                            }) {
                                Text("Créer Session")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                            .padding(.horizontal, 20)


                            // 🔹 Bouton "Modifier Session" (Action à ajouter)
                            Button(action: {
                                selectedView = "ModificationSessionView"
                            }) {
                                Text("Modifier Session")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                }
            }
        }
    }
}

// 🔹 **Prévisualisation**
struct SessionView_Previews: PreviewProvider {
    static var previews: some View {
        SessionView(selectedView: .constant("Session"))
    }
}
