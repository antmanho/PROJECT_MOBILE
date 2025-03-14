import SwiftUI

struct SessionModificationView: View {
    @StateObject private var viewModel = SessionModificationViewModel()
    @State private var showFilterOptions = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header and Search bar
                headerView
                
                // Sessions table
                if viewModel.isLoading && viewModel.sessions.isEmpty {
                    loadingView
                } else {
                    // Table with sessions
                    sessionTableView
                }
            }
            
            // Notification overlay
            notificationOverlay
            
            // Loading overlay
            if viewModel.isLoading && !viewModel.sessions.isEmpty {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                            .scaleEffect(2.0)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
        .navigationTitle("Modification des Sessions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            Text("MODIFICATION-SESSION")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "#333"))
                .padding(.vertical)
            
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Rechercher...", text: $viewModel.searchText)
                        .font(.system(size: 16))
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.black, lineWidth: 2)
                        .background(Color.white)
                )
                
                Button(action: {
                    showFilterOptions = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                }
                .sheet(isPresented: $showFilterOptions) {
                    Text("Options de filtrage")
                        .padding()
                }
            }
            .padding()
            .background(Color.white)
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Chargement des sessions...")
                .scaleEffect(1.5)
                .padding()
            Spacer()
        }
    }
    
    private var sessionTableView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Table header
                sessionTableHeader
                
                // Table rows
                ForEach(Array(viewModel.filteredSessions.enumerated()), id: \.element.id) { index, session in
                    sessionRow(session: session, index: index)
                }
                
                // Save button
                Button(action: {
                    viewModel.saveChanges()
                }) {
                    Text("Sauvegarder toutes les modifications")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#808080"))
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                        .padding(.vertical)
                }
                .disabled(viewModel.isLoading)
            }
            .padding()
        }
    }
    
    private var sessionTableHeader: some View {
        HStack {
            Group {
                Text("Nom de session")
                Text("Adresse")
                Text("Date de début")
                Text("Date de fin")
                Text("Charge")
                Text("Frais fixe")
                Text("Frais %")
                Text("Description")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, 10)
            .lineLimit(1)
        }
        .background(Color(hex: "#808080"))
        .cornerRadius(8)
    }
    
    private func sessionRow(session: Session, index: Int) -> some View {
        VStack {
            // Mobile view: One field per line
            if UIDevice.current.userInterfaceIdiom == .phone {
                mobileSessionRow(session: session, index: index)
            } else {
                // Desktop/tablet view: Table row
                desktopSessionRow(session: session, index: index)
            }
        }
        .padding()
        .background(index % 2 == 0 ? Color(hex: "#f9f9f9") : Color(hex: "#e0e0e0"))
        .cornerRadius(8)
    }
    
    private func mobileSessionRow(session: Session, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldRow(title: "Nom", value: Binding(
                get: { session.Nom_session },
                set: { 
                    var updatedSession = session
                    updatedSession.Nom_session = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            fieldRow(title: "Adresse", value: Binding(
                get: { session.adresse_session },
                set: {
                    var updatedSession = session
                    updatedSession.adresse_session = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            dateFieldRow(title: "Début", value: Binding(
                get: { session.date_debut },
                set: {
                    var updatedSession = session
                    updatedSession.date_debut = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            dateFieldRow(title: "Fin", value: Binding(
                get: { session.date_fin },
                set: {
                    var updatedSession = session
                    updatedSession.date_fin = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            numberFieldRow(title: "Charge", value: Binding(
                get: { session.Charge_totale },
                set: {
                    var updatedSession = session
                    updatedSession.Charge_totale = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            decimalFieldRow(title: "Frais fixe", value: Binding(
                get: { session.Frais_depot_fixe },
                set: {
                    var updatedSession = session
                    updatedSession.Frais_depot_fixe = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            decimalFieldRow(title: "Frais %", value: Binding(
                get: { session.Frais_depot_percent },
                set: {
                    var updatedSession = session
                    updatedSession.Frais_depot_percent = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            fieldRow(title: "Description", value: Binding(
                get: { session.Description },
                set: {
                    var updatedSession = session
                    updatedSession.Description = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            
            if session.isModified == true {
                Text("Modifié")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
    }
    
    private func desktopSessionRow(session: Session, index: Int) -> some View {
        HStack(alignment: .top) {
            // Nom session
            TextField("Nom", text: Binding(
                get: { session.Nom_session },
                set: { 
                    var updatedSession = session
                    updatedSession.Nom_session = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            // Adresse
            TextField("Adresse", text: Binding(
                get: { session.adresse_session },
                set: {
                    var updatedSession = session
                    updatedSession.adresse_session = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            // Date de début
            DatePicker(
                "",
                selection: Binding(
                    get: { dateFromString(session.date_debut) },
                    set: {
                        var updatedSession = session
                        updatedSession.date_debut = dateToString($0)
                        viewModel.filteredSessions[index] = updatedSession
                        viewModel.markAsModified(index)
                    }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
            .padding(4)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            // Date de fin
            DatePicker(
                "",
                selection: Binding(
                    get: { dateFromString(session.date_fin) },
                    set: {
                        var updatedSession = session
                        updatedSession.date_fin = dateToString($0)
                        viewModel.filteredSessions[index] = updatedSession
                        viewModel.markAsModified(index)
                    }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
            .padding(4)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            // Charge totale
            TextField("Charge", value: Binding(
                get: { session.Charge_totale },
                set: {
                    var updatedSession = session
                    updatedSession.Charge_totale = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ), formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            // Frais dépôt fixe
            TextField("Frais fixe", value: Binding(
                get: { session.Frais_depot_fixe },
                set: {
                    var updatedSession = session
                    updatedSession.Frais_depot_fixe = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ), formatter: decimalFormatter)
            .keyboardType(.decimalPad)
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            // Frais dépôt pourcentage
            TextField("Frais %", value: Binding(
                get: { session.Frais_depot_percent },
                set: {
                    var updatedSession = session
                    updatedSession.Frais_depot_percent = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ), formatter: decimalFormatter)
            .keyboardType(.decimalPad)
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
            
            // Description
            TextField("Description", text: Binding(
                get: { session.Description },
                set: {
                    var updatedSession = session
                    updatedSession.Description = $0
                    viewModel.filteredSessions[index] = updatedSession
                    viewModel.markAsModified(index)
                }
            ))
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(4)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .overlay(
            session.isModified == true ?
            Text("Modifié")
                .font(.caption2)
                .foregroundColor(.blue)
                .padding(4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
                .padding(2)
                .alignmentGuide(.trailing) { d in d[.trailing] }
                .position(x: 20, y: 15)
            : nil
        )
    }
    
    private var notificationOverlay: some View {
        Group {
            if viewModel.showNotification {
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
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                }
                .padding()
                .transition(.move(edge: .top))
                .animation(.easeInOut, value: viewModel.showNotification)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
    
    // Helper functions
    private func fieldRow(title: String, value: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
            
            TextField(title, text: value)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(4)
        }
    }
    
    private func dateFieldRow(title: String, value: Binding<String>) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
            
            DatePicker(
                "",
                selection: Binding(
                    get: { dateFromString(value.wrappedValue) },
                    set: { value.wrappedValue = dateToString($0) }
                ),
                displayedComponents: .date
            )
            .labelsHidden()
        }
    }
    
    private func numberFieldRow(title: String, value: Binding<Int>) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
            
            TextField(title, value: value, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(4)
        }
    }
    
    private func decimalFieldRow(title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .frame(width: 100, alignment: .leading)
            
            TextField(title, value: value, formatter: decimalFormatter)
                .keyboardType(.decimalPad)
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(4)
        }
    }
    
    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    private func dateFromString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    private func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
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

struct SessionModificationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SessionModificationView()
        }
    }
}