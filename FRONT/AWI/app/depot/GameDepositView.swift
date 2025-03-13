// GameDepositView.swift

import SwiftUI
import PhotosUI

struct GameDepositView: View {
    @StateObject private var viewModel = GameDepositViewModel()
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, nomJeu, quantite, prix, editeur, description
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // Header with ID for scrolling
                    Text("DEPOT")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.vertical)
                        .id("top")
                    
                    // Main form
                    formContent
                    
                    // Submit button
                    submitButton
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                .onChange(of: viewModel.showNotification) { newValue in
                    if newValue {
                        withAnimation {
                            scrollProxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
            .overlay(
                // Notification overlay
                Group {
                    if viewModel.showNotification {
                        notificationView
                    }
                }
            )
            .overlay(
                // Loading overlay
                Group {
                    if viewModel.isLoading {
                        loadingView
                    }
                }
            )
        }
        .navigationTitle("Dépôt")
    }
    
    // MARK: - Form Content
    
    private var formContent: some View {
        VStack(alignment: .center, spacing: 15) {
            // Session selection
            VStack(alignment: .leading, spacing: 5) {
                Text("Session")
                    .font(.headline)
                
                Picker("Choisissez une session", selection: $viewModel.selectedSessionId) {
                    Text("Choisissez une session").tag("")
                    
                    ForEach(viewModel.sessions) { session in
                        Text("\(session.Nom_session) (\(session.id_session))")
                            .tag(session.id_session)
                    }
                }
                .onChange(of: viewModel.selectedSessionId) { _ in
                    viewModel.onSessionChange()
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
            
            // Session information if selected
            if let session = viewModel.selectedSession {
                sessionInfoView(session: session)
            }
            
            // Required fields
            requiredFieldsView
            
            // Immediate sale checkbox
            CheckboxFieldView(
                title: "Mise en vente immédiate",
                isChecked: $viewModel.isInSale
            )
            
            // Fee payment checkbox
            CheckboxFieldView(
                title: "Les \(String(format: "%.2f", viewModel.depositFee))€ de dépôt sont payés",
                isChecked: $viewModel.isPaye
            )
            
            // Payment error message
            if let error = viewModel.paymentError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 5)
            }
            
            // Optional fields section
            optionalFieldsSection
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func sessionInfoView(session: Session) -> some View {
        VStack(alignment: .center, spacing: 5) {
            Text("Informations de la session")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Frais dépôt fixe : \(String(format: "%.2f", session.Frais_depot_fixe))€")
                    Text("Frais dépôt (%) : \(String(format: "%.1f", session.Frais_depot_percent))%")
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 1)
        )
    }
    
    private var requiredFieldsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Email field
            VStack(alignment: .leading) {
                Text("Email du vendeur")
                    .font(.headline)
                
                TextField("Email du vendeur", text: $viewModel.emailVendeur)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Game name field
            VStack(alignment: .leading) {
                Text("Nom du jeu")
                    .font(.headline)
                
                TextField("Nom du jeu", text: $viewModel.nomJeu)
                    .focused($focusedField, equals: .nomJeu)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Quantity field
            VStack(alignment: .leading) {
                Text("Quantité")
                    .font(.headline)
                
                TextField("Quantité", text: $viewModel.quantiteDeposee)
                    .focused($focusedField, equals: .quantite)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Unit price field
            VStack(alignment: .leading) {
                Text("Prix unitaire (€)")
                    .font(.headline)
                
                TextField("Prix unitaire", text: $viewModel.prixUnit)
                    .focused($focusedField, equals: .prix)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Field error message
            if let error = viewModel.fieldError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding(.top, 5)
            }
        }
    }
    
    private var optionalFieldsSection: some View {
        VStack(alignment: .leading) {
            Button(action: {
                withAnimation {
                    viewModel.toggleOptionalFields()
                }
            }) {
                HStack {
                    Image(systemName: viewModel.showOptionalFields ? "chevron.up" : "chevron.down")
                    Text("Champs optionnels")
                    Spacer()
                }
                .foregroundColor(.gray)
            }
            
            if viewModel.showOptionalFields {
                VStack(alignment: .leading, spacing: 15) {
                    // Publisher field
                    VStack(alignment: .leading) {
                        Text("Éditeur")
                            .font(.headline)
                        
                        TextField("Éditeur", text: $viewModel.editeur)
                            .focused($focusedField, equals: .editeur)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Description field
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.headline)
                        
                        TextEditor(text: $viewModel.description)
                            .focused($focusedField, equals: .description)
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Image picker
                    VStack(alignment: .leading) {
                        Text("Image du jeu")
                            .font(.headline)
                        
                        Button(action: {
                            isPickerPresented = true
                        }) {
                            HStack {
                                Image(systemName: "photo")
                                Text(selectedImage == nil ? "Choisir une image" : "Changer l'image")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(8)
                                .padding(.top, 5)
                        }
                    }
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImage: $selectedImage, viewModel: viewModel)
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            focusedField = nil // dismiss keyboard
            viewModel.onSubmit()
        }) {
            Text("AJOUTER")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding(.vertical)
    }
    
    // MARK: - Helper Views
    
    private var notificationView: some View {
        VStack {
            HStack {
                Text(viewModel.notificationMessage)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    viewModel.closeNotification()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(viewModel.notificationType == .success ? Color.green : Color.red)
            .cornerRadius(8)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .transition(.move(edge: .top))
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding()
                
                Text("Chargement...")
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Supporting Views

struct CheckboxFieldView: View {
    let title: String
    @Binding var isChecked: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                isChecked.toggle()
            }) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isChecked ? .blue : .gray)
            }
        }
        .padding(.vertical, 5)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var viewModel: GameDepositViewModel
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage else { return }
                    self?.parent.selectedImage = image
                    self?.parent.viewModel.setImage(image)
                }
            }
        }
    }
}

// Preview provider
struct GameDepositView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GameDepositView()
        }
    }
}