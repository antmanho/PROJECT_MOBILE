import SwiftUI
import PhotosUI
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

    @State private var selectedImage: UIImage? = nil
    @State private var photosPickerItem: PhotosPickerItem?

    let sessions: [Session] = [
        Session(id: 1, nom: "Session 1", fraisDepotFixe: 5, fraisDepotPercent: 10),
        Session(id: 2, nom: "Session 2", fraisDepotFixe: 7, fraisDepotPercent: 12)
    ]
    
    private var sessionPickerBinding: Binding<Int> {
        Binding<Int>(
            get: { selectedSession?.id ?? 0 },
            set: { newValue in selectedSession = sessions.first { $0.id == newValue } }
        )
    }

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
                            Text("DEPOT")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)

                            Toggle("Mise en vente immédiate", isOn: $estEnVente)
                                .tint(.blue)
                                .padding(.horizontal)

                            Picker("Choisissez une session", selection: sessionPickerBinding) {
                                Text("Sélectionnez une session").tag(0)
                                ForEach(sessions, id: \.id) { session in
                                    Text(session.nom).tag(session.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal)

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
                            

                            // Sélection d'image
                            PhotosPicker(selection: $photosPickerItem, matching: .images, photoLibrary: .shared()) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 20))
                                    Text("Choisir une image")
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }

                            // Afficher l'image choisie
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 250, maxHeight: 250)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            }
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
                }
            }
        }
        .onChange(of: photosPickerItem) { newItem in
            Task {
                if let loadedImageData = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: loadedImageData) {
                    selectedImage = uiImage
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
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}

struct Session {
    var id: Int
    var nom: String
    var fraisDepotFixe: Int
    var fraisDepotPercent: Int
}
