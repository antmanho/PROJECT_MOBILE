import SwiftUI

struct WithdrawalView: View {
    @StateObject private var viewModel = WithdrawalViewModel()
    @State private var navigateToList = false
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundLayer
                
                // Form Content
                VStack(spacing: 0) {
                    // Title and form
                    formContainer
                }
                .padding()
                
                // Error alert
                if viewModel.showError {
                    errorAlert
                }
                
                // Navigation link (hidden)
                NavigationLink(
                    destination: WithdrawalListView(email: viewModel.emailParticulier),
                    isActive: $navigateToList,
                    label: { EmptyView() }
                )
            }
            .navigationTitle("Retrait")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fermer") {
                        isEmailFocused = false
                    }
                }
            }
            .onTapGesture {
                isEmailFocused = false
            }
        }
    }
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        ZStack {
            Image("sport") // Replace with your actual image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            Color.white
                .opacity(0.9)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    // MARK: - Form Content
    
    private var formContainer: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Spacer()
                
                VStack(spacing: 20) {
                    // Form Title
                    Text("RETRAIT D'UN JEU")
                        .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                    
                    // Email Field
                    TextField("Email particulier", text: $viewModel.emailParticulier)
                        .font(.system(size: min(geometry.size.width * 0.05, 24)))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .focused($isEmailFocused)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .onChange(of: viewModel.emailParticulier) { _ in
                            viewModel.resetError()
                        }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Submit Button
                    Button(action: {
                        isEmailFocused = false
                        if viewModel.validateForm() {
                            navigateToList = true
                        }
                    }) {
                        Text("Afficher Liste")
                            .font(.system(size: min(geometry.size.width * 0.06, 28), weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .disabled(!viewModel.isValid)
                    .opacity(viewModel.isValid ? 1 : 0.6)
                    
                    Spacer()
                }
                .padding()
                .frame(width: geometry.size.width * 0.8)
                .background(Color.white.opacity(0.97))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 3)
                )
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    // MARK: - Error Alert
    
    private var errorAlert: some View {
        VStack {
            Spacer()
            
            HStack {
                Text(viewModel.errorMessage)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    viewModel.resetError()
                }) {
                    Text("OK")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding()
            }
            .background(Color.red)
            .cornerRadius(8)
            .padding()
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: viewModel.showError)
        .zIndex(1)
    }
}

// MARK: - Withdrawal List View (Placeholder)

struct WithdrawalListView: View {
    let email: String
    
    var body: some View {
        VStack {
            Text("Liste des jeux pour le retrait")
                .font(.title)
                .padding()
            
            Text("Email: \(email)")
                .font(.headline)
            
            Spacer()
        }
        .navigationTitle("Liste de Retrait")
    }
}

// MARK: - Preview Provider

struct WithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalView()
    }
}