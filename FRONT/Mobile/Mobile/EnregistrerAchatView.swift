import SwiftUI
import UserNotifications

struct EnregistrerAchatView: View {
    @State private var idStock: String = ""
    @State private var quantiteVendue: String = ""

    let onConfirmerAchat: (String, String) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 40)

                        VStack(spacing: 15) {
                            Text("ENREGISTRER UN ACHAT")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)

                            TextField("ID Stock", text: $idStock)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.numberPad)

                            TextField("Quantité Vendue", text: $quantiteVendue)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)
                                .keyboardType(.numberPad)

                            Button {
                                onConfirmerAchat(idStock, quantiteVendue)
                                scheduleNotification() // Appel ici
                            } label: {
                                Text("Confirmer l’achat")
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

    // Fonction pour déclencher la notification
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Achat enregistré"
        content.body = "Votre achat a été enregistré avec succès."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur notification: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview
struct EnregistrerAchatView_Previews: PreviewProvider {
    static var previews: some View {
        EnregistrerAchatView { id, quantite in
            print("Achat confirmé : ID Stock \(id), Quantité \(quantite)")
        }
    }
}
