import SwiftUI

struct BilanView: View {
    @State private var bilanParticulier = false
    @State private var sessionParticuliere = false
    @State private var emailParticulier = ""
    @State private var numeroSession = ""
    @State private var chargesFixes = ""

    let onAfficherBilanGraphe: (BilanData) -> Void

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

                        VStack(spacing: 15) {
                            Text("BILAN")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)

                            // Charges fixes
                            TextField("Charges fixes", text: $chargesFixes)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)

                            // Switch bilan global / particulier
                            Toggle("Bilan particulier", isOn: $bilanParticulier)
                                .tint(.blue)
                                .padding(.horizontal)

                            if bilanParticulier {
                                TextField("Email particulier", text: $emailParticulier)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .padding(.horizontal)
                            }

                            // Switch toutes les sessions / session particulière
                            Toggle("Session particulière", isOn: $sessionParticuliere)
                                .tint(.blue)
                                .padding(.horizontal)

                            if sessionParticuliere {
                                TextField("Numéro de session", text: $numeroSession)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal)
                            }

                            // Bouton de création de bilan
                            Button {
                                let data = BilanData(
                                    bilanParticulier: bilanParticulier,
                                    sessionParticuliere: sessionParticuliere,
                                    emailParticulier: emailParticulier,
                                    numeroSession: numeroSession,
                                    chargesFixes: Double(chargesFixes) ?? 0
                                )
                                onAfficherBilanGraphe(data)
                            } label: {
                                Text("Créer le Bilan")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .frame(maxWidth: 320)
                        .background(Color.white.opacity(0.97))
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
    }
}

// Modèle structuré pour envoyer des données
struct BilanData {
    let bilanParticulier: Bool
    let sessionParticuliere: Bool
    let emailParticulier: String
    let numeroSession: String
    let chargesFixes: Double
}

// Preview
struct BilanView_Previews: PreviewProvider {
    static var previews: some View {
        BilanView(onAfficherBilanGraphe: { _ in })
    }
}
