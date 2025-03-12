// BilanFormView.swift

import SwiftUI

struct BilanFormView: View {
    @StateObject private var bilanService = BilanService()
    @State private var bilanParticulier = false
    @State private var sessionParticuliere = false
    @State private var emailParticulier = ""
    @State private var numeroSession = ""
    @State private var chargesFixes: Double = 0
    @State private var errorMessage: String?
    @State private var navigateToChart = false
    @State private var bilanData: BilanData?
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Type de bilan")) {
                        HStack {
                            Text("Bilan global")
                            Spacer()
                            Toggle("", isOn: $bilanParticulier)
                                .labelsHidden()
                            Text("Bilan particulier")
                        }
                    }
                    
                    if bilanParticulier {
                        Section(header: Text("Email du particulier")) {
                            TextField("Email particulier", text: $emailParticulier)
                        }
                    }
                    
                    Section(header: Text("Session")) {
                        HStack {
                            Text("Toutes les sessions")
                            Spacer()
                            Toggle("", isOn: $sessionParticuliere)
                                .labelsHidden()
                            Text("Session particulière")
                        }
                    }
                    
                    if sessionParticuliere {
                        Section(header: Text("Numéro de session")) {
                            TextField("Numéro de session", text: $numeroSession)
                        }
                    }
                    
                    Section(header: Text("Charges fixes")) {
                        TextField("Charges fixes", value: $chargesFixes, format: .number)
                            .keyboardType(.decimalPad)
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button("Générer le bilan") {
                    creerBilan()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                NavigationLink(
                    destination: BilanGrapheView(
                        bilanData: bilanData,
                        bilanParticulier: bilanParticulier,
                        sessionParticuliere: sessionParticuliere,
                        emailParticulier: emailParticulier,
                        numeroSession: numeroSession,
                        chargesFixes: chargesFixes
                    ),
                    isActive: $navigateToChart
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Bilan Financier")
        }
    }
    
    private func creerBilan() {
        let requestBody = BilanRequestBody(
            bilanParticulier: bilanParticulier,
            sessionParticuliere: sessionParticuliere,
            emailParticulier: emailParticulier.isEmpty ? nil : emailParticulier,
            numeroSession: numeroSession.isEmpty ? nil : numeroSession,
            chargesFixes: chargesFixes
        )
        
        bilanService.creerBilanParticulier(requestBody: requestBody)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        self.errorMessage = "Erreur: \(error.localizedDescription)"
                    }
                },
                receiveValue: { response in
                    if let message = response.message {
                        self.errorMessage = message
                    } else {
                        self.bilanData = response
                        self.navigateToChart = true
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

struct BilanFormView_Previews: PreviewProvider {
    static var previews: some View {
        BilanFormView()
    }
}