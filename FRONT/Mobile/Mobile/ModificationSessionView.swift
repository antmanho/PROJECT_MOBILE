import SwiftUI

struct SessionMod: Identifiable {
    var id = UUID()
    var nom: String
    var adresse: String
    var dateDebut: Date
    var dateFin: Date
    var chargeTotale: Double
    var fraisFixe: Double
    var fraisPourcent: Double
    var description: String
}


struct ModificationSessionView: View {
    @Binding var selectedView: String

    @State private var sessions: [SessionMod] = [
        SessionMod(nom: "Festival A", adresse: "123 rue du Jeu", dateDebut: Date(), dateFin: Date(), chargeTotale: 100, fraisFixe: 10, fraisPourcent: 5, description: "Une super session"),
        SessionMod(nom: "BoardGame Days", adresse: "456 boulevard Ludique", dateDebut: Date(), dateFin: Date(), chargeTotale: 250, fraisFixe: 15, fraisPourcent: 7, description: "L'événement de l'année"),
        SessionMod(nom: "LudiQuest", adresse: "12 avenue Stratégie", dateDebut: Date(), dateFin: Date(), chargeTotale: 180, fraisFixe: 12, fraisPourcent: 6.5, description: "Festival centré sur les jeux de stratégie"),
        SessionMod(nom: "Meeple Expo", adresse: "789 chemin Meeple", dateDebut: Date(), dateFin: Date(), chargeTotale: 300, fraisFixe: 20, fraisPourcent: 8, description: "Rencontres entre passionnés et éditeurs")
    ]

    @State private var searchText = ""
    @State private var showNotification = false
    @State private var notificationMessage = ""
    @State private var notificationType: NotificationType = .success

    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    var body: some View {
        VStack {
            // 🔙 Bouton retour
            HStack {
                Button(action: {
                    selectedView = "Session"
                }) {
                    Image("retour")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding()
                }
                Spacer()
            }

            Text("MODIFICATION-SESSION")
                .font(.title)
                .bold()
                .padding(.top, -10)

            // 🔍 Recherche
            HStack {
                TextField("Rechercher...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {}) {
                    Image("rechercher")
                        .resizable()
                        .frame(width: 30, height: 30)
                }

                Button(action: {}) {
                    Image("reglage")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.horizontal)

            // 🔔 Notification
            if showNotification {
                HStack {
                    Text(notificationMessage)
                        .foregroundColor(.white)
                    Spacer()
                    Button("×") {
                        showNotification = false
                    }
                    .foregroundColor(.white)
                }
                .padding()
                .background(notificationType == .success ? Color.green : Color.red)
                .cornerRadius(10)
                .padding(.horizontal)
            }

            // 📋 Liste filtrée modifiable
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(sessions.indices, id: \ .self) { index in
                        if searchText.isEmpty || sessions[index].nom.lowercased().contains(searchText.lowercased()) {
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Nom", text: $sessions[index].nom)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)

                                Group {
                                    HStack {
                                        Text("Adresse:").bold()
                                        TextField("Adresse", text: $sessions[index].adresse)
                                    }

                                    HStack {
                                        Text("Date début:").bold()
                                        DatePicker("", selection: $sessions[index].dateDebut, displayedComponents: .date)
                                            .labelsHidden()
                                    }

                                    HStack {
                                        Text("Date fin:").bold()
                                        DatePicker("", selection: $sessions[index].dateFin, displayedComponents: .date)
                                            .labelsHidden()
                                    }

                                    HStack {
                                        Text("Charge totale:").bold()
                                        TextField("Charge totale", value: $sessions[index].chargeTotale, formatter: Self.decimalFormatter)
                                            .keyboardType(.decimalPad)
                                    }

                                    HStack {
                                        Text("Frais dépôt fixe:").bold()
                                        TextField("Frais fixe", value: $sessions[index].fraisFixe, formatter: Self.decimalFormatter)
                                            .keyboardType(.decimalPad)
                                    }

                                    HStack {
                                        Text("Frais dépôt %:").bold()
                                        TextField("Frais %", value: $sessions[index].fraisPourcent, formatter: Self.decimalFormatter)
                                            .keyboardType(.decimalPad)
                                    }

                                    HStack(alignment: .top) {
                                        Text("Description:").bold()
                                        TextEditor(text: $sessions[index].description)
                                            .frame(height: 60)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .stroke(Color.gray.opacity(0.4))
                                            )
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(radius: 2)
                        }
                    }
                }
                .padding(.vertical)
            }

            // 💾 Bouton de sauvegarde
            Button(action: {
                notificationMessage = "Modifications enregistrées !"
                notificationType = .success
                showNotification = true
            }) {
                Text("Sauvegarder toutes les modifications")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()
            }

            Spacer()
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
