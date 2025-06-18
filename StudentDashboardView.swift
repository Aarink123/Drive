import SwiftUI

struct StudentDashboardView: View {
    let username: String
    @Environment(\.presentationMode) var presentationMode
    @State private var showSignOutAlert = false
    @State private var drivingHours: Double = 25.5
    @State private var totalRequiredHours: Double = 50.0
    @State private var recentDrives: [DriveSession] = [
        DriveSession(date: "Today", duration: "45 min", location: "Local Roads", instructor: "Mom"),
        DriveSession(date: "Yesterday", duration: "30 min", location: "Highway Practice", instructor: "Dad"),
        DriveSession(date: "Dec 5", duration: "60 min", location: "Parking Lot", instructor: "Driving Instructor")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Welcome back,")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                
                                Text(username)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showSignOutAlert = true
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Progress Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "gauge.medium")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            Text("Driving Progress")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(Int(drivingHours)) / \(Int(totalRequiredHours)) hours")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text("\(Int((drivingHours / totalRequiredHours) * 100))%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            ProgressView(value: drivingHours, total: totalRequiredHours)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                            
                            Text("\(Int(totalRequiredHours - drivingHours)) hours remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ActionButton(
                                icon: "plus.circle.fill",
                                title: "Log Drive",
                                color: .green
                            ) {
                                // Handle log drive action
                            }
                            
                            ActionButton(
                                icon: "book.fill",
                                title: "Study Guide",
                                color: .blue
                            ) {
                                // Handle study guide action
                            }
                            
                            ActionButton(
                                icon: "calendar",
                                title: "Schedule",
                                color: .orange
                            ) {
                                // Handle schedule action
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Recent Drives
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Drives")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(recentDrives) { drive in
                                DriveRowView(drive: drive)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
            .background(Color.blue.opacity(0.1))
            .navigationBarHidden(true)
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}


struct DriveRowView: View {
    let drive: DriveSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(drive.location)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("with \(drive.instructor)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(drive.duration)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(drive.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct DriveSession: Identifiable {
    let id = UUID()
    let date: String
    let duration: String
    let location: String
    let instructor: String
}

struct StudentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        StudentDashboardView(username: "TeenLogin")
    }
}
