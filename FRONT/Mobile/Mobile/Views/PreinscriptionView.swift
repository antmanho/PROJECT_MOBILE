import SwiftUI
import UserNotifications

struct PreinscriptionView: View {
    @Binding var selectedView: String
    
    @StateObject private var viewModel = PreinscriptionViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundImage(geometry: geometry)
                
                ScrollView {
                    VStack {
                        Spacer(minLength: 40)
                        
                        formCard
                        
                        Spacer(minLength: 60)
                    }
                }
                
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            viewModel.requestNotificationPermission()
        }
    }
    
    // MARK: - Sous-vues
    
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        Image("sport")
            .resizable()
            .scaledToFill()
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
            .ignoresSafeArea()
    }
    
    private var formCard: some View {
        VStack(spacing: 10) {
            Text("PREINSCRIRE")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 10)
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal)
            
            Picker("Choisissez un rôle", selection: $viewModel.selectedRole) {
                Text("Choisissez un rôle").tag("")
                ForEach(viewModel.availableRoles, id: \.self) { role in
                    Text(role).tag(role)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .padding(.horizontal)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            if viewModel.isSuccess {
                Text("Préinscription effectuée avec succès!")
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.submitPreinscription()
            }) {
                Text("PREINSCRIRE")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!viewModel.email.isEmpty && !viewModel.selectedRole.isEmpty 
                              ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.email.isEmpty || viewModel.selectedRole.isEmpty || viewModel.isLoading)
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.black, lineWidth: 3)
        )
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Traitement en cours...")
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
            .padding(20)
            .background(Color.gray.opacity(0.8))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Méthodes utilitaires
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct PreinscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        PreinscriptionView(selectedView: .constant("Pré-Inscription"))
    }
}