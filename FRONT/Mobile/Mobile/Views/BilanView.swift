import SwiftUI

struct BilanView: View {
    @StateObject private var viewModel = BilanViewModel()
    
    // Closure appelée avec les données récupérées du back pour afficher les graphes
    let onAfficherBilanGraphe: (BilanGraphData) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                Image("sport")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                ScrollView {
                    VStack {
                        Spacer(minLength: 40)
                        
                        // Main content card
                        VStack(spacing: 15) {
                            Text("BILAN")
                                .font(.system(size: 24, weight: .bold))
                                .padding(.top, 10)
                            
                            // Form fields - now bound to ViewModel properties
                            TextField("Charges fixes", text: $viewModel.chargesFixes)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .padding(.horizontal)
                            
                            Toggle("Bilan particulier", isOn: $viewModel.bilanParticulier)
                                .tint(.blue)
                                .padding(.horizontal)
                            
                            if viewModel.bilanParticulier {
                                TextField("Email particulier", text: $viewModel.emailParticulier)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.emailAddress)
                                    .padding(.horizontal)
                            }
                            
                            Toggle("Session particulière", isOn: $viewModel.sessionParticuliere)
                                .tint(.blue)
                                .padding(.horizontal)
                            
                            if viewModel.sessionParticuliere {
                                TextField("Numéro de session", text: $viewModel.numeroSession)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .padding(.horizontal)
                            }
                            
                            // Submit button - calls ViewModel method
                            Button {
                                viewModel.fetchBilanData { data in
                                    onAfficherBilanGraphe(data)
                                }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .padding(.trailing, 5)
                                    }
                                    Text("Créer le Bilan")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isFormValid ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .disabled(!viewModel.isFormValid || viewModel.isLoading)
                            
                            // Error message from ViewModel
                            if let error = viewModel.error {
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .padding(.top, 5)
                                    .multilineTextAlignment(.center)
                            }
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
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

// Preview
struct BilanView_Previews: PreviewProvider {
    static var previews: some View {
        BilanView(onAfficherBilanGraphe: { data in
            print("BilanGraphData: \(data)")
        })
    }
}

// aide pour cacher le clavier par ce que c'est vu que c'est pas possible de le faire directement dans le code
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}