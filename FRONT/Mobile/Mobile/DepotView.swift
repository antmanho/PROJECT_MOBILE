import SwiftUI
import UserNotifications

struct DepotView: View {
    @State private var emailVendeur: String = ""
    @State private var nomJeu: String = ""
    @State private var prixUnit: String = ""
    @State private var quantiteDeposee: String = ""
    @State private var editeur: String = ""
    @State private var description: String = ""

    @State private var estEnVente: Bool = false
    @State private var selectedSession: Session? = nil
    @State private var showOptionalFields: Bool = false

    let sessions: [Session] = [
        Session(id: 1, nom: "Session 1", fraisDepotFixe: 5, fraisDepotPercent: 10),
        Session(id: 2, nom: "Session 2", fraisDepotFixe: 7, fraisDepotPercent: 12)
    ]
    
    /// Binding pour sélectionner l’ID de la Session dans le Picker
    private var sessionPickerBinding: Binding<Int> {
        Binding<Int>(
            get: {
                selectedSession?.id ?? 0
            },
            set: { newValue in
                selectedSession = sessions.first { $0.id == newValue }
            }
        )
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1) Image de fond qui prend tout l'écran
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                // 2) ScrollView pour tout le contenu
                ScrollView {
                    VStack {
                        Spacer(minLength: 40)

                        // ----------- FORMULAIRE -------------
                        VStack(spacing: 10) {
                            Text("DEPOT")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)

                            // Toggle en BLEU
                            Toggle("Mise en vente immédiate", isOn: $estEnVente)
                                .tint(.blue)
                                .padding(.horizontal)

                            // Picker : on utilise maintenant 'sessionPickerBinding'
                            Picker("Choisissez une session", selection: sessionPickerBinding) {
                                Text("Sélectionnez une session").tag(0)
                                ForEach(sessions, id: \.id) { session in
                                    Text(session.nom).tag(session.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal)

                            // Infos session choisie
                            if let session = selectedSession {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Frais dépôt fixe : \(session.fraisDepotFixe)€")
                                    Text("Frais dépôt (%) : \(session.fraisDepotPercent)%")
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }

                            // Champs de texte
                            TextField("Email du vendeur", text: $emailVendeur)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)

                            TextField("Nom du Jeu", text: $nomJeu)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)

                            TextField("Prix Unitaire (on lui devra)", text: $prixUnit)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.decimalPad)

                            TextField("Quantité", text: $quantiteDeposee)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.numberPad)

                            // Champs optionnels
                            Button {
                                showOptionalFields.toggle()
                            } label: {
                                Text(showOptionalFields
                                     ? "▲ Masquer les champs optionnels"
                                     : "▼ Afficher les champs optionnels")
                                .foregroundColor(.blue)
                            }
                            .padding(.top, 5)

                            if showOptionalFields {
                                TextField("Éditeur", text: $editeur)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal)

                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .border(Color.gray, width: 1)
                                    .padding(.horizontal)
                            }

                            // Bouton d'ajout
                            Button("Ajouter") {
                                scheduleLocalNotification()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
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
                    // 3) Largeur fixe = écran, hauteur min = écran
                    //    => le formulaire occupe l'écran si petit,
                    //    mais peut s'allonger si le contenu grandit
//                    .frame(width: geometry.size.width,
//                           minHeight: geometry.size.height)
                }
            }
        }
    }

    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Dépôt effectué"
        content.body = "Votre jeu a bien été déposé dans l’inventaire."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Session
struct Session {
    var id: Int
    var nom: String
    var fraisDepotFixe: Int
    var fraisDepotPercent: Int
}
