import SwiftUI

struct CreerSessionView: View {
    @State private var nomSession: String = ""
    @State private var adresseSession: String = ""
    @State private var dateDebut = Date()
    @State private var dateFin = Date()
    @State private var fraisDepotFixe: String = ""
    @State private var fraisDepotPercent: String = ""
    @State private var descriptionSession: String = ""
    @State private var showOptionalFields: Bool = false
    @State private var showAlert = false
    @State private var alertMessage: String = ""

    let onRetour: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 🔹 Image de fond
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 🔙 Bouton retour en haut à gauche (hors formulaire)
                    HStack {
                        Button(action: {
                            onRetour()
                        }) {
                            Image("retour")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding()
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()

                    // 🧾 Formulaire centré avec fond blanc
                    ScrollView {
                        VStack(spacing: 15) {
                            Text("CRÉER SESSION")
                                .font(.custom("Bangers", size: 30))
                                .padding(.top, 10)

                            TextField("Nom de la session", text: $nomSession)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            TextField("Adresse", text: $adresseSession)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            HStack(spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text("Date Début :")
                                        .font(.subheadline)
                                    DatePicker("", selection: $dateDebut, displayedComponents: .date)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)
                                }

                                VStack(alignment: .leading) {
                                    Text("Date Fin :")
                                        .font(.subheadline)
                                    DatePicker("", selection: $dateFin, displayedComponents: .date)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal)

                            .padding(.horizontal)

                            TextField("Frais dépôt fixe (€)", text: $fraisDepotFixe)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)

                            TextField("Frais dépôt variable (%)", text: $fraisDepotPercent)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)

                            Button(action: {
                                showOptionalFields.toggle()
                            }) {
                                Text(showOptionalFields ? "▲ Masquer les champs optionnels" : "▼ Afficher les champs optionnels")
                                    .foregroundColor(.blue)
                            }

                            if showOptionalFields {
                                TextEditor(text: $descriptionSession)
                                    .frame(height: 80)
                                    .border(Color.gray, width: 1)
                                    .padding(.horizontal)
                            }

                            Button(action: {
                                if nomSession.isEmpty || adresseSession.isEmpty || fraisDepotFixe.isEmpty || fraisDepotPercent.isEmpty {
                                    alertMessage = "Veuillez remplir tous les champs obligatoires."
                                    showAlert = true
                                } else {
                                    print("✅ Session créée avec succès")
                                    onRetour()
                                }
                            }) {
                                Text("CRÉER SESSION")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .frame(width: geometry.size.width * 0.9)
                    }

                    Spacer()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Erreur"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}
