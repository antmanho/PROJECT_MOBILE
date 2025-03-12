struct EmailVerificationView: View {
    let email: String
    @StateObject private var viewModel = EmailVerificationModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Vérification d'Email")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Un code de vérification a été envoyé à \(email)")
                .multilineTextAlignment(.center)
                .padding()
            
            // Code entry field
            HStack(spacing: 8) {
                ForEach(0..<6) { index in
                    TextField("", text: Binding(
                        get: { 
                            viewModel.getCodeDigit(at: index) 
                        },
                        set: { 
                            viewModel.setCodeDigit(at: index, to: $0)
                        }
                    ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 45, height: 55)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .font(.title2)
                    .onChange(of: viewModel.getCodeDigit(at: index)) { _ in
                        // Auto-advance to next field
                        if !viewModel.getCodeDigit(at: index).isEmpty && index < 5 {
                            // Focus next field (using UIKit focus in production)
                        }
                    }
                }
            }
            .padding(.vertical)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 5)
            }
            
            // Verify button
            Button(action: {
                viewModel.verifyCode(email: email)
            }) {
                Text("Vérifier")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(viewModel.isLoading || viewModel.verificationCode.count != 6)
            
            // Loading indicator
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            // Resend button
            Button(action: {
                viewModel.resendCode(email: email)
            }) {
                Text("Renvoyer le code")
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)
            .disabled(viewModel.isResending)
            
            if viewModel.isResending {
                Text("Envoi en cours...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Vérification")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $viewModel.showSuccessAlert) {
            Alert(
                title: Text("Vérification réussie"),
                message: Text("Votre compte a été vérifié avec succès."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
