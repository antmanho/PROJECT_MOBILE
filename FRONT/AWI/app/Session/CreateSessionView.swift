import SwiftUI

struct CreateSessionView: View {
    @StateObject private var viewModel = CreateSessionViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Notification banner
                if viewModel.showNotification {
                    notificationBanner
                }
                
                // Form
                formContent
            }
            .padding()
        }
        .navigationTitle("Créer une Session")
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    // Notification banner
    private var notificationBanner: some View {
        HStack {
            Text(viewModel.notificationMessage ?? "")
                .foregroundColor(Color.white)
            
            Spacer()
            
            Button(action: {
                viewModel.closeNotification()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.green)
        .cornerRadius(8)
        .padding(.bottom)
    }
    
    // Form content
    private var formContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("CRÉER SESSION")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Required fields
            Group {
                // Session name
                VStack(alignment: .leading) {
                    Text("Nom de la session")
                        .font(.headline)
                    
                    TextField("Nom de la session", text: $viewModel.session.Nom_session)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                }
                
                // Session address
                VStack(alignment: .leading) {
                    Text("Adresse")
                        .font(.headline)
                    
                    TextField("Adresse", text: $viewModel.session.adresse_session)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Start date
                VStack(alignment: .leading) {
                    Text("Date de début")
                        .font(.headline)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.startDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                
                // End date
                VStack(alignment: .leading) {
                    Text("Date de fin")
                        .font(.headline)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.endDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
                
                // Fixed fees
                VStack(alignment: .leading) {
                    Text("Frais de dépôt fixe (en euros)")
                        .font(.headline)
                    
                    TextField(
                        "Frais de dépôt fixe",
                        value: $viewModel.session.Frais_depot_fixe,
                        format: .number
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                }
                
                // Percentage fees
                VStack(alignment: .leading) {
                    Text("Frais de dépôt variable (en %)")
                        .font(.headline)
                    
                    TextField(
                        "Frais de dépôt pourcentage",
                        value: $viewModel.session.Frais_depot_percent,
                        format: .percent
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                }
            }
            
            // Optional fields toggle
            Button(action: {
                viewModel.toggleOptionalFields()
            }) {
                HStack {
                    Image(systemName: viewModel.showOptionalFields ? "chevron.up" : "chevron.down")
                    Text("Afficher les champs optionnels")
                    Spacer()
                }
            }
            .foregroundColor(.blue)
            .padding(.vertical, 8)
            
            // Optional fields
            if viewModel.showOptionalFields {
                VStack(alignment: .leading) {
                    Text("Description")
                        .font(.headline)
                    
                    TextEditor(text: $viewModel.session.Description)
                        .frame(height: 100)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            // Submit button
            Button(action: {
                viewModel.createSession()
            }) {
                Text("CRÉER SESSION")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.vertical)
            .disabled(viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Preview for SwiftUI Canvas
struct CreateSessionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateSessionView()
        }
    }
}