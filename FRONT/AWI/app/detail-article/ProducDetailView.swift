import SwiftUI

struct ProductDetailView: View {
    let productId: Int
    @StateObject private var viewModel = ProductDetailViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Back button
                backButton
                
                // Title
                Text("DÉTAILS DU PRODUIT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color(.darkGray))
                    .padding()
                
                if viewModel.isLoading {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else if let product = viewModel.product {
                    productDetailView(product)
                }
            }
            .padding()
        }
        .background(Color(hex: "#f9f9f9"))
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchProductDetails(id: productId)
        }
    }
    
    // MARK: - Subviews
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                
                Text("Retour")
                    .foregroundColor(.blue)
            }
            .frame(width: 100, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 1)
            )
        }
        .padding(.bottom, 10)
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(2)
                .padding()
            
            Text("Chargement...")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
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
                viewModel.fetchProductDetails(id: productId)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    private func productDetailView(_ product: Product) -> some View {
        VStack(spacing: 20) {
            // Product container
            HStack(alignment: .top, spacing: 20) {
                // Image
                productImageView(product)
                
                // Product info
                productInfoView(product)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Description section
            if let description = product.description, !description.isEmpty {
                descriptionView(description)
            }
        }
    }
    
    private func productImageView(_ product: Product) -> some View {
        Group {
            if let imageURL = product.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(product.fallbackImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    @unknown default:
                        Image(product.fallbackImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(maxWidth: .infinity)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5)
            } else {
                Image(product.fallbackImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
    }
    
    private func productInfoView(_ product: Product) -> some View {
        let (availabilityText, availabilityColor) = viewModel.availabilityStatus()
        
        return VStack(alignment: .leading, spacing: 12) {
            // Product name
            Text(product.nom_jeu)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            
            // Publisher
            if let editeur = product.editeur, !editeur.isEmpty {
                Text("Éditeur: \(editeur)")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Price
            HStack {
                Text("Prix:")
                    .font(.system(size: 18, weight: .semibold))
                
                Text(String(format: "%.2f €", product.prix_unit))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            // Quantity information
            VStack(alignment: .leading, spacing: 8) {
                Text("Initialement déposé: \(product.quantite_deposee)")
                    .font(.system(size: 16))
                
                Text("Vendu: \(product.quantite_vendu)")
                    .font(.system(size: 16))
                
                HStack {
                    Text("État:")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text(availabilityText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(availabilityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(availabilityColor.opacity(0.1))
                        )
                }
            }
            
            Spacer()
        }
        .padding(.leading)
    }
    
    private func descriptionView(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.headline)
                .padding(.bottom, 5)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview provider
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(productId: 1)
    }
}