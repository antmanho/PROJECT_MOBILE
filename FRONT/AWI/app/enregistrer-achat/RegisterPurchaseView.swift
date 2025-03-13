import SwiftUI

struct RegisterPurchaseView: View {
    @StateObject private var viewModel = RegisterPurchaseViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case stockId, soldQuantity
    }
    
    var body: some View {
        ScrollView {
            VStack {
                // Title
                Text("ENREGISTRER UN ACHAT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.vertical)
                
                // Form
                formContainer
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .overlay(
            notificationOverlay
        )
        .overlay(
            loadingOverlay
        )
        .navigationTitle("Enregistrer un Achat")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            // Dismiss keyboard when tapping outside fields
            focusedField = nil
        }
    }
    
    private var formContainer: some View {
        VStack(spacing: 20) {
            // Stock ID Field
            VStack(alignment: .leading, spacing: 8) {
                Text("ID Stock :")
                    .font(.headline)
                
                HStack {
                    TextField("ID Stock", value: $viewModel.stockId, format: .number)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .stockId)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            
            // Quantity Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Quantité Vendue :")
                    .font(.headline)
                
                HStack {
                    TextField("Quantité", value: $viewModel.soldQuantity, format: .number)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: .soldQuantity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            
            // Error message if any
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.callout)
                    .padding(.top, 5)
            }
            
            // Submit button
            Button(action: {
                focusedField = nil // Dismiss keyboard
                viewModel.submitPurchase()
            }) {
                Text("Confirmer l'achat")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(viewModel.isLoading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var notificationOverlay: some View {
        Group {
            if viewModel.showNotification {
                VStack {
                    HStack {
                        Text("Votre jeu a été enregistré.")
                            .foregroundColor(Color(UIColor.systemGreen))
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.closeNotification()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(UIColor.systemGreen))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGreen).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(UIColor.systemGreen).opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: viewModel.showNotification)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        
                        Text("Traitement en cours...")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                }
            }
        }
    }
}

struct RegisterPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterPurchaseView()
        }
    }
}