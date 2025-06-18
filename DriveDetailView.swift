import SwiftUI

struct DriveDetailView: View {
    let drive: DriveHistory
    @Environment(\.dismiss) var dismiss
    
    // Theming colors
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))

    var body: some View {
        ZStack {
            deepBlue.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack {
                        Text("Drive Analysis")
                            .font(.largeTitle).fontWeight(.bold)
                        Text("Drive on: \(drive.date)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                    
                    // Main Score
                    ScoreRingView(score: drive.score)
                    
                    // Key Safety Events (Placeholder data)
                    KeySafetyEventsView()
                    
                    // Performance Breakdown from shared component
                    PerformanceBreakdownView(breakdown: drive.performanceBreakdown)
                    
                    // Maneuver Analysis from shared component
                    ManeuverAnalysisListView(analyses: drive.maneuverAnalyses)
                    
                }
                .padding()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray.opacity(0.8))
            }
            .padding()
        }
    }
}


// MARK: - Subviews for DriveDetailView

struct ScoreRingView: View {
    let score: Int
    
    var scoreColor: Color {
        switch score {
        case 90...100: return .green
        case 80...89: return .yellow
        default: return .orange
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 15)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(score) / 100.0)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: scoreColor.opacity(0.5), radius: 10)

            VStack {
                Text("\(score)")
                    .font(.system(size: 60, weight: .bold))
                Text("Drive Score")
                    .font(.headline)
            }
            .foregroundColor(.white)
        }
        .frame(width: 200, height: 200)
    }
}

struct KeySafetyEventsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Safety Events")
                .font(.title2).fontWeight(.bold).foregroundColor(.white)
            
            HStack(spacing: 12) {
                SafetyEventCard(icon: "exclamationmark.triangle.fill", value: "3", label: "Hard Braking", color: .red)
                SafetyEventCard(icon: "arrow.up.right", value: "2", label: "Rapid Accel.", color: .orange)
                SafetyEventCard(icon: "speedometer", value: "1", label: "Speeding", color: .yellow)
            }
        }
    }
}

struct SafetyEventCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            Text(value)
                .font(.title).fontWeight(.bold)
            Text(label)
                .font(.caption).fontWeight(.medium)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}


// MARK: - Preview
struct DriveDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DriveDetailView(drive: AppData().kids[0].driveHistory[0])
    }
}
