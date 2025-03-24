import SwiftUI
import UserNotifications

struct RetraitListeView: View {
    let email: String
    
    let onRetour: () -> Void   // Retour vers la vue précédente
    let onInvité: () -> Void   // Retour en mode invité
    
    @StateObject private var viewModel: GameWithdrawalViewModel
    
    init(email: String, onRetour: @escaping () -> Void, onInvité: @escaping () -> Void) {
        self.email = email
        self.onRetour = onRetour
        self.onInvité = onInvité
        self._viewModel = StateObject(wrappedValue: GameWithdrawalViewModel(email: email))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer(minLength: 30)
                        
                        headerView
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        gamesTableView(geometry: geometry)
                        
                        withdrawButton
                        
                        Spacer(minLength: 50)
                    }
                }
                
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                viewModel.fetchGames()
            }
        }
    }
    
    // MARK: - Sous-vues
    
    private var headerView: some View {
        HStack {
            Button(action: onRetour) {
                Image("retour")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .padding()
            }
            Spacer()
            Text("Retirer jeu")
                .font(.system(size: 22, weight: .bold))
                .padding(.trailing, 50)
            Spacer()
        }
        .padding(.top, 10)
    }
    
    private func gamesTableView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                cellHeader("ID Stock", geometry: geometry)
                cellHeader("Nom du Jeu", geometry: geometry)
                cellHeader("Prix Demandé", geometry: geometry)
                cellHeader("Sélection", geometry: geometry)
            }
            .frame(height: 40)
            .background(Color.gray.opacity(0.2))
            
            ForEach(viewModel.games.indices, id: \.self) { index in
                HStack(spacing: 0) {
                    cellBody("\(viewModel.games[index].stockId)", geometry: geometry)
                    cellBody(viewModel.games[index].name, geometry: geometry)
                    cellBody(String(format: "%.2f€", viewModel.games[index].price), geometry: geometry)
                    Toggle("", isOn: Binding(
                        get: { viewModel.games[index].isSelected },
                        set: { _ in viewModel.toggleSelection(for: index) }
                    ))
                    .labelsHidden()
                    .frame(width: columnWidth(geometry), height: 40)
                    .border(Color.black)
                }
            }
        }
        .border(Color.black)
        .frame(width: geometry.size.width * 0.9)
        .padding(.horizontal, geometry.size.width * 0.05)
    }
    
    private var withdrawButton: some View {
        Button(action: {
            viewModel.withdrawSelectedGames()
        }) {
            Text("Retirer les jeux sélectionnés")
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 17, weight: .bold))
                .background(viewModel.hasSelectedGames ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!viewModel.hasSelectedGames || viewModel.isLoading)
        .padding(.horizontal, 20)
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
    
    private func columnWidth(_ geometry: GeometryProxy) -> CGFloat {
        (geometry.size.width * 0.9) / 4
    }
    
    private func cellHeader(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(width: columnWidth(geometry), height: 40)
            .border(Color.black)
    }
    
    private func cellBody(_ text: String, geometry: GeometryProxy) -> some View {
        Text(text)
            .font(.system(size: 13))
            .multilineTextAlignment(.center)
            .frame(width: columnWidth(geometry), height: 40)
            .border(Color.black)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct RetraitListeView_Previews: PreviewProvider {
    static var previews: some View {
        RetraitListeView(email: "test@example.com", onRetour: { }, onInvité: { })
    }
}