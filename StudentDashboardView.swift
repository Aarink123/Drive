import SwiftUI

struct StudentDashboardView: View {
    @EnvironmentObject var appData: AppData
    let username: String
    
    @Environment(\.presentationMode) var presentationMode
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))
    private let secondaryBlue = Color(#colorLiteral(red: 0.1568627451, green: 0.4, blue: 0.6156862745, alpha: 1))
    
    private var student: Kid? {
        appData.kids.first { $0.name == "Aarin" } ?? appData.kids.first
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [deepBlue, secondaryBlue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                if let student = student {
                    ScrollView {
                        VStack(spacing: 24) {
                            StudentHeaderView(username: student.name)
                                .padding(.horizontal)

                            StudentScoreCardView(student: student)
                                .padding(.horizontal)
                            
                            DrivingProgressView(
                                drivingHours: student.metrics.totalHoursDriven,
                                totalRequiredHours: 40.0
                            )
                            .padding(.horizontal)
                                                        
                            WeeklyGoalsSectionView()
                                .padding(.horizontal)
                            
                            StudentRecentDrivesView(driveHistory: student.driveHistory)
                                .padding(.horizontal)
                            
                        }
                        .padding(.vertical)
                    }
                } else {
                    VStack {
                        Text("Could not load student data.")
                            .foregroundColor(.white)
                        Text("Please log in again.")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}


// MARK: - Student Dashboard Subviews

struct StudentHeaderView: View {
    let username: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome back,")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                Text(username)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}

struct StudentScoreCardView: View {
    let student: Kid
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Recent Score")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: CGFloat(student.recentDriveScore) / 100)
                        .stroke(getScoreColor(student.recentDriveScore), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: student.recentDriveScore)
                    
                    Text("\(student.recentDriveScore)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 120, height: 120)
                
                VStack(alignment: .leading, spacing: 12) {
                    ScoreBreakdownRow(title: "Past Week", score: student.weekScore)
                    ScoreBreakdownRow(title: "Past Month", score: student.monthScore)
                    ScoreBreakdownRow(title: "Safety Rating", scoreText: student.metrics.safetyRating.title, color: student.metrics.safetyRating.color)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func getScoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70...89: return .orange
        default: return .red
        }
    }
}

struct DrivingProgressView: View {
    let drivingHours: Double
    let totalRequiredHours: Double
    
    private var progress: Double {
        return min(drivingHours / totalRequiredHours, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress to License")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total Hours Driven")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Text("\(String(format: "%.1f", drivingHours)) / \(String(format: "%.0f", totalRequiredHours)) hrs")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                Text("\(String(format: "%.0f", max(0, totalRequiredHours - drivingHours))) hours remaining")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
}

struct StudentRecentDrivesView: View {
    let driveHistory: [DriveHistory]
    @State private var selectedDrive: DriveHistory?

    var body: some View {
        VStack(alignment: .leading) {
            Text("My Recent Drives")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            if driveHistory.isEmpty {
                Text("No drives logged yet. Go log your first drive!")
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(driveHistory.prefix(4)) { drive in
                        Button(action: { selectedDrive = drive }) {
                            DriveHistoryRow(date: drive.date, distance: drive.distance, score: drive.score)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .sheet(item: $selectedDrive) { drive in
            DriveDetailView(drive: drive)
        }
    }
}

// MARK: - Preview Provider
struct StudentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        StudentDashboardView(username: "TeenLogin")
            .environmentObject(AppData())
    }
}
