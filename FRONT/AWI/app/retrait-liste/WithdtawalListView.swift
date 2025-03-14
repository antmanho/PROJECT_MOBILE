import SwiftUI

struct WithdrawalListView: View {
    @StateObject private var viewModel: WithdrawalListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(email: String) {
        _viewModel = StateObject(wrappedValue: WithdrawalListViewModel(email: email))
    }
    
    var body: some View {
        ZStack {
            // Background
            backgroundLayer
            
            // Content
            VStack(spacing: 20) {
                // Header
                Text("Retirer jeu")
                    .font(.system(size: UIScreen.main.bounds.width * 0.06))
                    .fontWeight(.bold)
                    .padding(.top)
                
                if viewModel.isLoading && viewModel.games.isEmpty {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage, viewModel.games.isEmpty {
                    errorView(message: errorMessage)
                } else {
                    // Game list and form
                    formContent
                }
            }
            .padding()
            
            // Back button
            backButton
            
            // Alert overlay
            if viewModel.showAlert {
                alertOverlay
            }
            
            // Success overlay
            if viewModel.showSuccess {
                successOverlay
            }
            
            // Loading overlay
            if viewModel.isLoading && !viewModel.games.isEmpty {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                            .scaleEffect(2.0)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
        .navigationBarHidden(true)
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
    
    // MARK: - Back Button
    
    private var backButton: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 16)
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Content Views
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Chargement des jeux...")
                .scaleEffect(1.5)
                .padding()
            Spacer()
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
                .padding()
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                viewModel.fetchGames()
            }) {
                Text("Réessayer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
    }
    
    private var formContent: some View {
        VStack {
            // Form with table
            Form {
                Section {
                    if viewModel.games.isEmpty {
                        Text("Aucun jeu disponible pour le retrait")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        gameTable
                    }
                }
                .listRowBackground(Color.white.opacity(0.8))
                
                Section {
                    Button(action: {
                        viewModel.withdrawSelectedGames()
                    }) {
                        Text("Retirer les jeux sélectionnés")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .listRowBackground(Color.clear)
                    .disabled(viewModel.games.filter { $0.isSelected }.isEmpty)
                }
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 3)
                )
        )
        .padding(.horizontal)
    }
    
    private var gameTable: some View {
        VStack(spacing: 0) {
            // Table header
            HStack {
                Text("ID Stock")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                
                Text("Nom du Jeu")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                
                Text("Prix")
                    .font(.headline)
                    .frame(width: 65, alignment: .trailing)
                    .padding(.vertical, 10)
                
                Text("Sélection")
                    .font(.headline)
                    .frame(width: 80)
                    .padding(.vertical, 10)
            }
            .padding(.horizontal)
            .background(Color.gray.opacity(0.2))
            
            // Table rows
            ForEach(viewModel.games) { game in
                gameRow(game)
                    .background(
                        viewModel.games.firstIndex(where: { $0.id_stock == game.id_stock })! % 2 == 0 ?
                            Color.white.opacity(0.7) : Color.gray.opacity(0.1)
                    )
            }
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
    
    private func gameRow(_ game: Game) -> some View {
        HStack {
            Text("\(game.id_stock)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            
            Text(game.nom_jeu)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
            
            Text("\(String(format: "%.2f", game.Prix_unit)) €")
                .frame(width: 65, alignment: .trailing)
                .lineLimit(1)
            
            Button(action: {
                viewModel.toggleSelection(for: game)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            game.isSelected ?
                                RoundedRectangle(cornerRadius: 4).fill(Color.blue.opacity(0.2)) :
                                RoundedRectangle(cornerRadius: 4).fill(Color.white)
                        )
                    
                    if game.isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .frame(width: 80)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Alert & Success Overlays
    
    private var alertOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        viewModel.showAlert = false
                    }
                }
            
            VStack(spacing: 20) {
                Text("Attention")
                    .font(.headline)
                
                Text(viewModel.alertMessage)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    withAnimation {
                        viewModel.showAlert = false
                    }
                }) {
                    Text("OK")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.showAlert)
    }
    
    private var successOverlay: some View {
        VStack {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text(viewModel.successMessage)
                    .foregroundColor(.green)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        viewModel.showSuccess = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.green)
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
            .padding()
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.easeInOut, value: viewModel.showSuccess)
        .zIndex(2)
    }
}

struct WithdrawalListView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalListView(email: "example@example.com")
    }
}