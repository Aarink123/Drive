//
//  MapsView.swift
//  DriveQuest
//
//  Created by Aarin Karamchandani on 6/17/25.
//


import SwiftUI
import MapKit
import CoreLocation

struct MapsView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var selectedStudent = 0
    @State private var showLocationAlert = false
    @State private var students: [StudentLocation] = []
    
    // Listen to location enabled setting
    @AppStorage("locationEnabled") private var locationEnabled = true
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map View
                Map(coordinateRegion: $region, annotationItems: students) { student in
                    MapAnnotation(coordinate: student.coordinate) {
                        StudentMapPin(student: student)
                    }
                }
                
                // Top Controls
                VStack {
                    HStack {
                        // Student Selector or Status
                        if locationEnabled && !students.isEmpty {
                            Menu {
                                ForEach(students.indices, id: \.self) { index in
                                    Button(action: {
                                        selectedStudent = index
                                        centerMapOnStudent(students[index])
                                    }) {
                                        HStack {
                                            Circle()
                                                .fill(students[index].isActive ? Color.green : Color.gray)
                                                .frame(width: 8, height: 8)
                                            Text(students[index].name)
                                            Spacer()
                                            if selectedStudent == index {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Circle()
                                        .fill(students[selectedStudent].isActive ? Color.green : Color.gray)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(students[selectedStudent].name)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            }
                        } else if locationEnabled {
                            // Show loading state when location is enabled but no data
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Getting location...")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        } else {
                            // Show location disabled state
                            HStack {
                                Image(systemName: "location.slash")
                                    .foregroundColor(.red)
                                Text("Location Not Found")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        }
                        
                        Spacer()
                        
                        // Location Permission Button
                        Button(action: {
                            if !locationEnabled {
                                // Show alert to enable in settings
                                showLocationAlert = true
                            } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                                showLocationAlert = true
                            } else {
                                locationManager.requestLocationPermission()
                            }
                        }) {
                            Image(systemName: getLocationButtonIcon())
                                .font(.title2)
                                .foregroundColor(getLocationButtonColor())
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                
                // Bottom Student Info Card - Only show if location is enabled and we have data
                if locationEnabled && !students.isEmpty {
                    VStack {
                        Spacer()
                        
                        StudentInfoCard(student: students[selectedStudent])
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                } else if !locationEnabled {
                    // Show location disabled message at bottom
                    VStack {
                        Spacer()
                        
                        LocationDisabledCard()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Live Location")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                setupLocationTracking()
            }
            .onChange(of: locationEnabled) { newValue in
                handleLocationEnabledChange(newValue)
            }
            .onChange(of: locationManager.currentLocation) { newLocation in
                if locationEnabled {
                    updateCurrentUserLocation(newLocation)
                }
            }
            .alert("Location Settings", isPresented: $showLocationAlert) {
                if !locationEnabled {
                    Button("Go to App Settings") {
                        // This would ideally navigate to your app's settings
                        // For now, we'll just show system settings
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                } else {
                    Button("Go to Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if !locationEnabled {
                    Text("Location tracking is disabled in app settings. Please enable it in the Settings tab to see your live location.")
                } else {
                    Text("Please enable location services in System Settings to track location.")
                }
            }
        }
    }
    
    private func getLocationButtonIcon() -> String {
        if !locationEnabled {
            return "location.slash"
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "location.fill"
        case .denied, .restricted:
            return "location.slash"
        default:
            return "location"
        }
    }
    
    private func getLocationButtonColor() -> Color {
        if !locationEnabled {
            return .red
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .blue
        case .denied, .restricted:
            return .red
        default:
            return .orange
        }
    }
    
    private func setupLocationTracking() {
        if locationEnabled {
            locationManager.requestLocationPermission()
            addCurrentUserAsStudent()
        } else {
            students = []
            // Set map to default location
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    private func handleLocationEnabledChange(_ enabled: Bool) {
        if enabled {
            locationManager.requestLocationPermission()
            addCurrentUserAsStudent()
        } else {
            students = []
            locationManager.stopLocationUpdates()
            // Reset to default location
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    private func addCurrentUserAsStudent() {
        guard locationEnabled else { return }
        
        // Add current user as the primary student
        let currentUser = StudentLocation(
            name: "Me",
            coordinate: locationManager.currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 33.7490, longitude: -84.3880),
            isActive: true,
            lastUpdate: Date(),
            speed: locationManager.currentLocation?.speed ?? 0.0,
            status: determineStatus(from: locationManager.currentLocation)
        )
        
        students = [currentUser]
        selectedStudent = 0
        
        // Center map on current location if available
        if let location = locationManager.currentLocation {
            centerMapOnCoordinate(location.coordinate)
        }
    }
    
    private func updateCurrentUserLocation(_ newLocation: CLLocation?) {
        guard locationEnabled, let location = newLocation else { return }
        
        let updatedUser = StudentLocation(
            name: students.isEmpty ? "Me" : students[0].name,
            coordinate: location.coordinate,
            isActive: true,
            lastUpdate: Date(),
            speed: max(0, location.speed * 2.237), // Convert m/s to mph
            status: determineStatus(from: location)
        )
        
        if students.isEmpty {
            students = [updatedUser]
        } else {
            students[0] = updatedUser
        }
        
        // Update map region to follow current location
        centerMapOnCoordinate(location.coordinate)
    }
    
    private func determineStatus(from location: CLLocation?) -> StudentStatus {
        guard let location = location else { return .parked }
        
        let speedMph = location.speed * 2.237 // Convert m/s to mph
        
        if speedMph > 5 {
            return .driving
        } else if speedMph > 1 {
            return .walking
        } else {
            return .parked
        }
    }
    
    private func centerMapOnStudent(_ student: StudentLocation) {
        centerMapOnCoordinate(student.coordinate)
    }
    
    private func centerMapOnCoordinate(_ coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
    }
}

struct LocationDisabledCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.title2)
                .foregroundColor(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Location Disabled")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Enable location tracking in Settings to see live location")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct StudentMapPin: View {
    let student: StudentLocation
    
    var body: some View {
        ZStack {
            // Pin Background
            Circle()
                .fill(student.isActive ? Color.blue : Color.gray)
                .frame(width: 40, height: 40)
            
            // Status Icon
            Image(systemName: student.status.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .overlay(
            // Pulse animation for active students
            student.isActive ?
            Circle()
                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                .scaleEffect(1.5)
                .opacity(0.8)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: student.isActive)
            : nil
        )
    }
}

struct StudentInfoCard: View {
    let student: StudentLocation
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(student.isActive ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(student.status.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            // Speed (always show)
            HStack(spacing: 4) {
                Image(systemName: "speedometer")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("\(Int(max(0, student.speed))) mph")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            // Last update
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text(formatLastUpdate(student.lastUpdate))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private func formatLastUpdate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 1)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(.gray)
                    .tracking(0.5)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .shadow(color: .white.opacity(0.7), radius: 1, x: 0, y: 1)
            }
            
            Spacer()
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
            .frame(width: 65, height: 55)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: 3, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

// MARK: - Enhanced Location Manager (Singleton)
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var locationHistory: [CLLocation] = []
    private let maxHistoryCount = 10
    private var isLocationEnabled = true
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var currentSpeed: Double = 0.0
    @Published var isMoving: Bool = false
    @Published var averageSpeed: Double = 0.0
    @Published var totalDistance: Double = 0.0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 1 // Update every 1 meter for more precision
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func setLocationEnabled(_ enabled: Bool) {
        isLocationEnabled = enabled
        
        if enabled {
            startLocationUpdates()
        } else {
            stopLocationUpdates()
            // Clear current location when disabled
            DispatchQueue.main.async {
                self.currentLocation = nil
                self.currentSpeed = 0.0
                self.isMoving = false
            }
        }
    }
    
    func requestLocationPermission() {
        guard isLocationEnabled else { return }
        
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // User needs to go to settings
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func startLocationUpdates() {
        guard isLocationEnabled && (authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways) else { return }
        
        // Enable background location updates for better tracking
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        locationManager.startUpdatingLocation()
        
        // Start a timer for regular status updates
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.isLocationEnabled {
                self.updateMovementStatus()
            }
        }
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    private func updateMovementStatus() {
        guard isLocationEnabled else { return }
        
        // Calculate if device is moving based on recent location changes
        if locationHistory.count >= 3 {
            let recentLocations = Array(locationHistory.suffix(3))
            let distances = zip(recentLocations.dropLast(), recentLocations.dropFirst()).map { loc1, loc2 in
                loc1.distance(from: loc2)
            }
            
            let totalRecentDistance = distances.reduce(0, +)
            let timeSpan = recentLocations.last!.timestamp.timeIntervalSince(recentLocations.first!.timestamp)
            
            if timeSpan > 0 {
                let calculatedSpeed = (totalRecentDistance / timeSpan) * 2.237 // Convert to mph
                DispatchQueue.main.async {
                    self.currentSpeed = max(0, calculatedSpeed)
                    self.isMoving = calculatedSpeed > 0.5 // Moving if speed > 0.5 mph
                }
            }
        }
        
        // Calculate average speed from all location history
        if locationHistory.count >= 2 {
            let speeds = locationHistory.compactMap { location in
                location.speed >= 0 ? location.speed * 2.237 : nil // Convert to mph, filter invalid speeds
            }
            
            if !speeds.isEmpty {
                DispatchQueue.main.async {
                    self.averageSpeed = speeds.reduce(0, +) / Double(speeds.count)
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isLocationEnabled, let location = locations.last else { return }
        
        // Only update if the location is recent and accurate
        if location.timestamp.timeIntervalSinceNow > -10 && location.horizontalAccuracy < 50 {
            // Add to location history
            locationHistory.append(location)
            if locationHistory.count > maxHistoryCount {
                locationHistory.removeFirst()
            }
            
            DispatchQueue.main.async {
                self.currentLocation = location
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            
            switch self.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                if self.isLocationEnabled {
                    self.startLocationUpdates()
                }
            case .denied, .restricted:
                self.stopLocationUpdates()
            default:
                break
            }
        }
    }
}

// MARK: - Data Models
struct StudentLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isActive: Bool
    let lastUpdate: Date
    let speed: Double
    let status: StudentStatus
}

enum StudentStatus {
    case driving, parked, walking
    
    var displayName: String {
        switch self {
        case .driving: return "Driving"
        case .parked: return "Parked"
        case .walking: return "Walking"
        }
    }
    
    var icon: String {
        switch self {
        case .driving: return "car.fill"
        case .parked: return "parkingsign"
        case .walking: return "figure.walk"
        }
    }
}

struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        MapsView()
    }
}
