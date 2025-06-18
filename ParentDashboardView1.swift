import SwiftUI

// Preview Provider for Xcode Previews
struct ParentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        ParentDashboardView1(username: "ParentLogin")
            .environmentObject(AppData()) // Provide a preview instance for the canvas
    }
}

// MARK: - Main Parent Dashboard View
struct ParentDashboardView1: View {
    let username: String
    @EnvironmentObject var appData: AppData
    @State private var selectedStudent = 0
    @State private var showDetailedMetrics = false
    @State private var showAIRecommendations = false
    @State private var showCourses = false
    @State private var showDriveHistory = false

    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))
    private let secondaryBlue = Color(#colorLiteral(red: 0.1568627451, green: 0.4, blue: 0.6156862745, alpha: 1))

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [deepBlue, secondaryBlue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        HeaderView(selectedStudent: $selectedStudent)
                            .padding(.horizontal)

                        if !appData.kids.isEmpty {
                            let currentStudent = appData.kids[selectedStudent]
                            
                            ScoreCardView(student: currentStudent)
                                .padding(.horizontal)
                                .onTapGesture {
                                    showDetailedMetrics = true
                                }
                            
                            ActionButtonsScrollView(
                                onShowAI: { showAIRecommendations = true },
                                onShowCourses: { showCourses = true },
                                onShowHistory: { showDriveHistory = true }
                            )
                            
                            WeeklyGoalsSectionView()
                                .padding(.horizontal)
                            
                            // Now passes real drive history data
                            DriveHistorySectionView(driveHistory: currentStudent.driveHistory)
                                .padding(.horizontal)
                        } else {
                            Text("No students added yet. Go to Settings to add a kid.")
                                .foregroundColor(.white.opacity(0.7))
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showDetailedMetrics) {
                if !appData.kids.isEmpty {
                    DetailedMetricsView(student: appData.kids[selectedStudent])
                }
            }
            .sheet(isPresented: $showAIRecommendations) {
                if !appData.kids.isEmpty {
                    AIDetailedRecommendationsView(student: appData.kids[selectedStudent])
                }
            }
            .sheet(isPresented: $showCourses) {
                CoursesView()
            }
            .sheet(isPresented: $showDriveHistory) {
                // Now passes real drive history data
                if !appData.kids.isEmpty {
                    DriveHistoryMasterView(driveHistory: appData.kids[selectedStudent].driveHistory)
                }
            }
        }
    }
}

// MARK: - Redesigned Dashboard Subviews

struct HeaderView: View {
    @EnvironmentObject var appData: AppData
    @Binding var selectedStudent: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Parent Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            if appData.kids.count > 1 {
                Menu {
                    ForEach(appData.kids.indices, id: \.self) { index in
                        Button(action: {
                            selectedStudent = index
                        }) {
                            Text(appData.kids[index].name)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.white.opacity(0.8))
                        Text(appData.kids[selectedStudent].name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
}

struct ScoreCardView: View {
    let student: Kid
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(student.name)'s Recent Score")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
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
            Text("Tap to see detailed drive metrics")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
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

struct ScoreBreakdownRow: View {
    let title: String
    var score: Int? = nil
    var scoreText: String? = nil
    var color: Color? = nil

    var body: some View {
        HStack {
            Circle()
                .fill(color ?? getScoreColor(score ?? 0))
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            if let scoreValue = score {
                Text("\(scoreValue)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            } else if let text = scoreText {
                Text(text)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
        }
    }

    private func getScoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70...89: return .orange
        default: return .red
        }
    }
}

struct ActionButtonsScrollView: View {
    var onShowAI: () -> Void
    var onShowCourses: () -> Void
    var onShowHistory: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ActionButton(icon: "brain.head.profile", title: "AI Insights", color: .yellow, action: onShowAI)
                ActionButton(icon: "book.closed.fill", title: "Courses", color: .blue, action: onShowCourses)
                ActionButton(icon: "list.star", title: "All Drives", color: .green, action: onShowHistory)
            }
            .padding(.horizontal)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 80)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

// EXPANDED Weekly Goals Section
struct WeeklyGoalsSectionView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("This Week's Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                GoalCard(title: "Smooth Acceleration", goal: "Practice gradual acceleration from stops", progress: 12, target: 20, color: .cyan)
                GoalCard(title: "Speed Management", goal: "Maintain speed within 5mph of limit", progress: 20, target: 50, color: .orange)
                GoalCard(title: "Complete Stops", goal: "Perform full 3-second stops at all signs", progress: 35, target: 40, color: .red)
                GoalCard(title: "Turn Signals", goal: "Use signals 100ft before every turn", progress: 45, target: 50, color: .yellow)
                GoalCard(title: "Lane Centering", goal: "Stay centered in the lane on straightaways", progress: 15, target: 30, color: .green)
            }
        }
    }
}

struct GoalCard: View {
    let title: String
    let goal: String
    let progress: Int
    let target: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text("\(progress)/\(target) drives")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Text(goal)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            ProgressView(value: Double(progress), total: Double(target))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// UPDATED Drive History Section
struct DriveHistorySectionView: View {
    let driveHistory: [DriveHistory]
    @State private var selectedDrive: DriveHistory?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent Drive History")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)

            VStack(spacing: 12) {
                ForEach(driveHistory.prefix(3)) { drive in
                    Button(action: { selectedDrive = drive }) {
                        DriveHistoryRow(date: drive.date, distance: drive.distance, score: drive.score)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .sheet(item: $selectedDrive) { drive in
            DriveDetailView(drive: drive)
        }
    }
}

struct DriveHistoryRow: View {
    let date: String
    let distance: Double
    let score: Int

    var body: some View {
        HStack {
            Image(systemName: "car.fill")
                .font(.title2)
                .foregroundColor(getScoreColor(score))
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text("Trip on \(date)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(String(format: "%.1f", distance)) miles")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(getScoreColor(score))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func getScoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70...89: return .orange
        default: return .red
        }
    }
}

// MARK: - Enhanced Modal Views

struct AIDetailedRecommendationsView: View {
    let student: Kid
    @Environment(\.presentationMode) var presentationMode
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))
    
    var body: some View {
        NavigationView {
            ZStack {
                deepBlue.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("AI-Powered Insights")
                                .font(.largeTitle).fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Hyper-Detailed Analysis for \(student.name)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }.padding([.horizontal, .top])
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Key Focus Areas")
                                .font(.title2).fontWeight(.bold).foregroundColor(.white)
                            FocusAreaCard(icon: "exclamationmark.triangle.fill", title: "Hard Braking", value: "\(student.metrics.hardBraking) events", recommendation: "Increase following distance, especially in stop-and-go traffic. Aim for smoother, more gradual braking.", color: .red)
                            FocusAreaCard(icon: "forward.fill", title: "Rapid Acceleration", value: "\(student.metrics.rapidAcceleration) events", recommendation: "Apply gentle pressure to the accelerator. Smooth starts from a stoplight improve control and save fuel.", color: .orange)
                            FocusAreaCard(icon: "speedometer", title: "Speeding", value: "\(student.metrics.speedingInstances) events", recommendation: "Use GPS to stay aware of speed limits. A crucial step for safety and avoiding tickets.", color: .purple)
                        }.padding(.horizontal)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("AI Pattern Analysis")
                                .font(.title2).fontWeight(.bold).foregroundColor(.white)
                            InsightCard(icon: "mappin.and.ellipse", title: "Location Habits", text: "AI has noticed that most speeding instances occur on the main highway bypass. Suggest reviewing the speed limits in that specific zone.")
                            InsightCard(icon: "clock.arrow.circlepath", title: "Time-of-Day Patterns", text: "Hard braking events are more frequent during the morning commute (7-8 AM). This may be due to rushing or heavier traffic.")
                        }.padding(.horizontal)
                        
                        SafetyRatingCard(rating: student.metrics.safetyRating)
                            .padding(.horizontal)

                    }
                    .padding(.vertical)
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.white))
            .navigationBarHidden(true)
        }
    }
}

struct FocusAreaCard: View {
    let icon: String
    let title: String
    let value: String
    let recommendation: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(recommendation)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(.cyan)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// EXPANDED Courses View
struct CoursesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCourse: Course?

    let courses = [
        Course(title: "Defensive Driving", description: "Anticipate and avoid hazards", duration: "2 hours", icon: "shield.checkered", color: .green),
        Course(title: "Night Driving", description: "Master driving in low light", duration: "1.5 hours", icon: "moon.stars.fill", color: .purple),
        Course(title: "Highway Skills", description: "Merging, lane changes, and more", duration: "3 hours", icon: "road.lanes", color: .blue),
        Course(title: "Parking Pro", description: "Parallel, angled, and lot parking", duration: "1 hour", icon: "parkingsign.circle.fill", color: .orange)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1)).edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Driving Courses")
                                .font(.largeTitle).fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Unlock new skills and improve safety")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }.padding([.horizontal, .top])

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                            ForEach(courses) { course in
                                CourseCard(course: course)
                                    .onTapGesture {
                                        if course.title == "Defensive Driving" {
                                            self.selectedCourse = course
                                        }
                                    }
                            }
                        }.padding(.horizontal)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.white))
            .navigationBarHidden(true)
            .sheet(item: $selectedCourse) { course in
                CourseDetailView(course: course)
            }
        }
    }
}

struct CourseDetailView: View {
    let course: Course
    @Environment(\.presentationMode) var presentationMode
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))

    let modules = [
        "Module 1: The Scan, Identify, Predict, Decide, Execute (SIPDE) System",
        "Module 2: Mastering the 3-Second Following Distance Rule",
        "Module 3: Identifying Escape Routes in Traffic",
        "Module 4: Hazard Recognition in Urban vs. Rural Areas",
        "Module 5: Final Assessment Simulation"
    ]
    
    var body: some View {
        ZStack {
            deepBlue.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ZStack(alignment: .bottomLeading) {
                        course.color.brightness(-0.2)
                            .frame(height: 200)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: course.icon)
                                .font(.system(size: 40))
                            Text(course.title)
                                .font(.largeTitle).fontWeight(.bold)
                            Text(course.description)
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Course Modules")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        ForEach(modules, id: \.self) { moduleName in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(moduleName)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                Spacer()
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Start Course")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(course.color)
                            .cornerRadius(15)
                            .padding()
                    }
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}


struct Course: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let icon: String
    let color: Color
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            course.color
                .brightness(-0.2)

            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.8), .clear]),
                startPoint: .bottom,
                endPoint: .center
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: course.icon)
                        .font(.title)
                        .foregroundColor(course.color)
                    Spacer()
                    Text(course.duration)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text(course.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(course.description)
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            .padding(20)
        }
        .frame(height: 200)
        .cornerRadius(20)
        .overlay(
            course.title == "Defensive Driving" ?
                RoundedRectangle(cornerRadius: 20).stroke(Color.yellow, lineWidth: 2) : nil
        )
    }
}

// UPDATED Drive History Master View
struct DriveHistoryMasterView: View {
    let driveHistory: [DriveHistory]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDrive: DriveHistory?
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))

    var body: some View {
        NavigationView {
             ZStack {
                deepBlue.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Complete Drive History")
                                .font(.largeTitle).fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Review every logged drive")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }.padding([.horizontal, .top])
                        
                        VStack(spacing: 12) {
                            ForEach(driveHistory) { drive in
                                Button(action: { selectedDrive = drive }) {
                                    DriveHistoryRow(date: drive.date, distance: drive.distance, score: drive.score)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }.padding(.horizontal)
                    }
                }
             }
             .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.white))
            .navigationBarHidden(true)
            .sheet(item: $selectedDrive) { drive in
                DriveDetailView(drive: drive)
            }
        }
    }
}

// MARK: - Required Supporting Views & Data Models

struct DetailedMetricsView: View {
    let student: Kid
    @Environment(\.presentationMode) var presentationMode
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))
    
    var body: some View {
        NavigationView {
            ZStack {
                deepBlue.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("\(student.name)'s Drive Details")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Most Recent Drive Session")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top)
                        
                        SafetyBannerView(rating: student.metrics.safetyRating)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Drive Metrics")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                MetricCard(icon: "speedometer", title: "Avg Speed", value: "\(String(format: "%.1f", student.metrics.averageSpeed)) mph", color: .blue)
                                MetricCard(icon: "location.fill", title: "Distance", value: "\(String(format: "%.1f", student.metrics.distanceDrove)) mi", color: .green)
                                MetricCard(icon: "clock.fill", title: "Duration", value: "\(student.metrics.driveDuration) min", color: .orange)
                                MetricCard(icon: "star.fill", title: "Drive Score", value: "\(student.recentDriveScore)", color: getScoreColor(student.recentDriveScore))
                            }
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Safety Incidents")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                IncidentRow(icon: "exclamationmark.triangle.fill", title: "Hard Braking", count: student.metrics.hardBraking, color: .red)
                                IncidentRow(icon: "forward.fill", title: "Rapid Acceleration", count: student.metrics.rapidAcceleration, color: .orange)
                                IncidentRow(icon: "speedometer", title: "Speeding", count: student.metrics.speedingInstances, color: .purple)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func getScoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100: return .green
        case 70...89: return .orange
        default: return .red
        }
    }
}

struct SafetyBannerView: View {
    let rating: SafetyRating
    
    var body: some View {
        HStack {
            Image(systemName: rating.icon)
                .font(.title)
                .foregroundColor(rating.color)
            
            VStack(alignment: .leading) {
                Text(rating.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(rating.color)
                
                Text(rating.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(rating.color.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct IncidentRow: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SafetyRatingCard: View {
    let rating: SafetyRating
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: rating.icon)
                .font(.largeTitle)
                .foregroundColor(rating.color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Overall Safety Rating")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(rating.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(rating.color)
                Text(rating.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

enum SafetyRating {
    case safe, moderate, risky
    
    var title: String {
        switch self {
        case .safe: return "Safe"
        case .moderate: return "Moderate"
        case .risky: return "Risky"
        }
    }
    
    var description: String {
        switch self {
        case .safe: return "Excellent habits. Keep up the safe driving!"
        case .moderate: return "Good driving with a few areas for improvement."
        case .risky: return "Multiple safety concerns detected. Review incidents."
        }
    }
    
    var color: Color {
        switch self {
        case .safe: return .green
        case .moderate: return .orange
        case .risky: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .safe: return "checkmark.shield.fill"
        case .moderate: return "exclamationmark.shield.fill"
        case .risky: return "xmark.shield.fill"
        }
    }
}

struct DriveMetrics {
    let averageSpeed: Double
    let distanceDrove: Double
    let hardBraking: Int
    let rapidAcceleration: Int
    let speedingInstances: Int
    let safetyRating: SafetyRating
    let driveDuration: Int
    let totalHoursDriven: Double
}
