import SwiftUI

struct SellerPaymentListView: View {
    let sellerEmail: String
    @StateObject private var viewModel = SellerPaymentListViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Page title
                Text("HISTORIQUE DES VENTES")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                if viewModel.isLoading && viewModel.salesHistory.isEmpty {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if viewModel.salesHistory.isEmpty {
                    emptyStateView
                } else {
                    // Sales history table
                    salesTableView
                    
                    // Total amount
                    totalAmountView
                    
                    // Pay button
                    payButtonView
                }
            }
            .padding()
            .background(
                backgroundLayer
            )
        }
        .overlay(
            backButton,
            alignment: .topLeading
        )
        .overlay(
            notificationOverlay
        )
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchSalesHistory(for: sellerEmail)
        }
    }
    
    // MARK: - Background
    
    private var backgroundLayer: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            Image("sport") // Replace with your image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.1)
        }
    }
    
    // MARK: - Content Views
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Chargement des données...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .padding()
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
                .padding()
            
            Button(action: {
                viewModel.fetchSalesHistory(for: sellerEmail)
            }) {
                Text("Réessayer")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("Aucune vente trouvée pour ce vendeur")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(height: 200)
    }
    
    private var salesTableView: some View {
        VStack {
            // Table header
            HStack {
                Text("Nom du Jeu")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                
                Text("Qté")
                    .frame(width: 50)
                    .font(.headline)
                
                Text("Prix")
                    .frame(width: 70)
                    .font(.headline)
                
                Text("Payé")
                    .frame(width: 60)
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            
            // Table rows
            ForEach(viewModel.salesHistory) { sale in
                salesRow(for: sale)
                    .background(
                        Group {
                            if viewModel.salesHistory.firstIndex(where: { $0.id == sale.id })! % 2 == 0 {
                                Color.white.opacity(0.6)
                            } else {
                                Color.gray.opacity(0.1)
                            }
                        }
                    )
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func salesRow(for sale: SaleItem) -> some View {
        HStack {
            Text(sale.nom_jeu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            
            Text("\(sale.Quantite_vendu)")
                .frame(width: 50)
            
            Text(String(format: "%.2f €", sale.Prix_unit))
                .frame(width: 70)
            
            Text(sale.vendeur_paye ? "Oui" : "Non")
                .frame(width: 60)
                .foregroundColor(sale.vendeur_paye ? .green : .red)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            // Navigate to detail view if needed
        }
    }
    
    private var totalAmountView: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("Somme totale due:")
                    .font(.headline)
                
                Text("\(String(format: "%.2f €", viewModel.totalAmountDue))")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
        .padding()
    }
    
    private var payButtonView: some View {
        Button(action: {
            viewModel.paySeller()
        }) {
            Text("Payer le vendeur")
                .fontWeight(.bold)
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding(.horizontal, 50)
        .padding(.bottom)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1.0)
    }
    
    // MARK: - Back Button
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .font(.title)
                .foregroundColor(.blue)
                .padding(12)
                .background(Circle().fill(Color.white))
                .shadow(color: Color.black.opacity(0.2), radius: 3)
        }
        .padding()
    }
    
    // MARK: - Notification
    
    private var notificationOverlay: some View {
        Group {
            if viewModel.showNotification {
                VStack {
                    HStack {
                        Text(viewModel.notificationMessage)
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
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
                            )
                    )
                }
                .padding()
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.easeInOut, value: viewModel.showNotification)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .zIndex(1)
            }
        }
    }
}

// MARK: - Preview Provider

struct SellerPaymentListView_Previews: PreviewProvider {
    static var previews: some View {
        SellerPaymentListView(sellerEmail: "example@example.com")
    }
}