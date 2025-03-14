// PaySellerView.swift

import SwiftUI

struct PaySellerView: View {
    @StateObject private var viewModel = PaySellerViewModel()
    @State private var navigateToList = false
    @State private var showNotification = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background
                    backgroundLayer
                    
                    // Form Content
                    ScrollView {
                        formContent(geometry: geometry)
                    }
                    
                    // Notification
                    if showNotification {
                        notificationOverlay
                    }
                    
                    // Navigation Link (hidden)
                    NavigationLink(
                        destination: SellerPaymentListView(sellerEmail: viewModel.sellerEmail),
                        isActive: $navigateToList,
                        label: { EmptyView() }
                    )
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationTitle("Payer un vendeur")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            Image("sport") // Replace with your actual background image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.1)
        }
    }
    
    // MARK: - Form Content
    
    private func formContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: geometry.size.height * 0.05)
            
            VStack(spacing: 20) {
                // Form Header
                Text("PAYER UN VENDEUR")
                    .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .bold))
                    .padding(.top, 20)
                
                // Email Input Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email du vendeur")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Email du vendeur...", text: $viewModel.sellerEmail)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(viewModel.showError ? Color.red : Color.gray, lineWidth: 1)
                        )
                    
                    if viewModel.showError {
                        Text(viewModel.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 20)
                
                // Submit Button
                Button(action: {
                    if viewModel.submitSellerEmail() {
                        navigateToList = true
                    }
                }) {
                    Text("Voir Historique des achats")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .disabled(!viewModel.isValid)
                .opacity(viewModel.isValid ? 1.0 : 0.6)
            }
            .frame(width: geometry.size.width * 0.8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black, lineWidth: 3)
            )
            
            Spacer()
        }
        .frame(minHeight: geometry.size.height)
    }
    
    // MARK: - Notification
    
    private var notificationOverlay: some View {
        VStack {
            HStack {
                Text("Redirection vers la liste des paiements...")
                    .foregroundColor(Color(UIColor.systemGreen))
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showNotification = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(UIColor.systemGreen))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .padding()
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: showNotification)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .zIndex(1)
    }
}

// MARK: - Helper Views and Extensions

// Placeholder for the destination view
struct SellerPaymentListView: View {
    let sellerEmail: String
    
    var body: some View {
        VStack {
            Text("Liste des paiements pour")
                .font(.title2)
            Text(sellerEmail)
                .font(.headline)
                .padding(.bottom)
            
            // This would be replaced with actual payment list
            Text("Historique des achats et paiements")
                .padding()
        }
        .navigationTitle("Historique")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Preview Provider
struct PaySellerView_Previews: PreviewProvider {
    static var previews: some View {
        PaySellerView()
            .previewDevice("iPhone 14")
        
        PaySellerView()
            .previewDevice("iPad Pro (11-inch)")
    }
}