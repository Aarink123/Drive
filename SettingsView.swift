import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appData: AppData
    @State private var showingAddKidForm = false
    @State private var showingEditAccount = false
    @State private var showingSubmissionMessage = false
    @State private var submissionMessageText = ""
    
    // Location permission state
    @AppStorage("locationEnabled") private var locationEnabled = true
    @StateObject private var locationManager = LocationManager.shared
    
    // Alert states
    @State private var showingSignOutAlert = false
    @State private var showingRemoveKidAlert = false
    @State private var showingLocationPermissionAlert = false
    @State private var kidToRemove: Kid? // Track which kid to remove
    
    // Preference states
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    Button(action: {
                        showingEditAccount = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Om Karamchandani")
                                    .foregroundColor(.primary)
                                    .font(.headline)
                                Text("Born: January 15, 1990")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Section(header: Text("Kids")) {
                    ForEach(appData.kids) { kid in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(kid.name)
                                    .font(.headline)
                                Text("Age: \(kid.age), State: \(kid.state)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let testDate = kid.expectedTestDate {
                                    Text("Test Date: \(testDate, style: .date)")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                            Spacer()
                            Button(action: {
                                kidToRemove = kid
                                showingRemoveKidAlert = true
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Button("Add Kid") {
                        showingAddKidForm = true
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("Privacy & Location")) {
                    Toggle("Enable Location Tracking", isOn: $locationEnabled)
                        .onChange(of: locationEnabled) { newValue in
                            if newValue {
                                showingLocationPermissionAlert = true
                            } else {
                                locationManager.setLocationEnabled(false)
                                submissionMessageText = "Location tracking disabled"
                                showingSubmissionMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showingSubmissionMessage = false
                                }
                            }
                        }
                    
                    if locationEnabled {
                        HStack {
                            Image(systemName: locationStatusIcon)
                                .foregroundColor(locationStatusColor)
                            Text(locationStatusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Use Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                    }
                }
                
                if showingSubmissionMessage {
                    Section {
                        Text(submissionMessageText)
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAddKidForm) {
                AddKidFormView(onSubmit: { kid in
                    appData.kids.append(kid)
                    submissionMessageText = "Kid added successfully!"
                    showingSubmissionMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showingSubmissionMessage = false
                    }
                })
            }
            .sheet(isPresented: $showingEditAccount) {
                EditAccountView()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Remove Kid", isPresented: $showingRemoveKidAlert) {
                Button("Remove", role: .destructive) {
                    if let kid = kidToRemove {
                        appData.kids.removeAll { $0.id == kid.id }
                        submissionMessageText = "Kid removed successfully!"
                        showingSubmissionMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showingSubmissionMessage = false
                        }
                        kidToRemove = nil
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to remove \(kidToRemove?.name ?? "this kid")?")
            }
            .alert("Enable Location Tracking", isPresented: $showingLocationPermissionAlert) {
                Button("Allow") {
                    locationManager.setLocationEnabled(true)
                    locationManager.requestLocationPermission()
                    submissionMessageText = "Location tracking enabled"
                    showingSubmissionMessage = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showingSubmissionMessage = false
                    }
                }
                Button("Cancel", role: .cancel) {
                    locationEnabled = false
                }
            } message: {
                Text("Allow location tracking to monitor live locations. You can change this setting later.")
            }
            .environmentObject(appData)
        }
    }
    
    private var locationStatusIcon: String {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "location.fill"
        case .denied, .restricted:
            return "location.slash"
        default:
            return "location"
        }
    }
    
    private var locationStatusColor: Color {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        case .denied, .restricted:
            return .red
        default:
            return .orange
        }
    }
    
    private var locationStatusText: String {
        if !locationEnabled {
            return "Location tracking disabled in app"
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location permission granted"
        case .denied, .restricted:
            return "Location permission denied - Go to Settings"
        case .notDetermined:
            return "Location permission not requested"
        @unknown default:
            return "Unknown location status"
        }
    }
}

// MARK: - Data Models

struct PerformanceBreakdown: Hashable {
    let control: Int
    let speed: Int
    let aware: Int
    let follow: Int
    let smooth: Int
}

struct ManeuverAnalysis: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let icon: String
    let grade: String
    let description: String
}

struct DriveHistory: Identifiable, Hashable {
    let id = UUID()
    let date: String
    let distance: Double
    let score: Int
    let performanceBreakdown: PerformanceBreakdown
    let maneuverAnalyses: [ManeuverAnalysis]
}

struct Kid: Identifiable {
    let id: UUID
    let name: String
    let age: String
    let state: String
    let expectedTestDate: Date?
    let metrics: DriveMetrics
    let recentDriveScore: Int
    let weekScore: Int
    let monthScore: Int
    let driveHistory: [DriveHistory]
}

struct AddKidFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var age = ""
    @State private var selectedState = "Georgia"
    @State private var expectedTestDate = Date()
    @State private var includeTestDate = false
    
    let onSubmit: (Kid) -> Void
    
    let usStates = [
        "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware",
        "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky",
        "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi",
        "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
        "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
        "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
        "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kid Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    
                    Picker("State", selection: $selectedState) {
                        ForEach(usStates, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Toggle("Include Expected License Test Date", isOn: $includeTestDate)
                    
                    if includeTestDate {
                        DatePicker("Expected Test Date", selection: $expectedTestDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Kid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        let newKid = Kid(
                            id: UUID(),
                            name: name,
                            age: age,
                            state: selectedState,
                            expectedTestDate: includeTestDate ? expectedTestDate : nil,
                            metrics: DriveMetrics(
                                averageSpeed: 0.0,
                                distanceDrove: 0.0,
                                hardBraking: 0,
                                rapidAcceleration: 0,
                                speedingInstances: 0,
                                safetyRating: .safe,
                                driveDuration: 0,
                                totalHoursDriven: 0.0
                            ),
                            recentDriveScore: 0,
                            weekScore: 0,
                            monthScore: 0,
                            driveHistory: []
                        )
                        onSubmit(newKid)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || age.isEmpty)
                }
            }
        }
    }
}

struct EditAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var firstName = "Om"
    @State private var lastName = "Karamchandani"
    @State private var username = "ParentLogin"
    @State private var dateOfBirth = Calendar.current.date(from: DateComponents(year: 1990, month: 1, day: 15)) ?? Date()
    @State private var email = "DriveQuestParentLogin@gmail.com"
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                }
                
                Section(header: Text("Account Details")) {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Change Password")) {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }
                
                Section {
                    Button("Save Changes") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || username.isEmpty || email.isEmpty)
                }
            }
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppData())
    }
}
