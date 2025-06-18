import SwiftUI

// MARK: - Data Models for New Features
struct Goal: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    var detailedTip: String
    var whyItMatters: String
    var progress: Int
    let target: Int
    let color: Color
    // Mock data for the new history chart
    let practiceHistory: [Int] = (0..<7).map { _ in Int.random(in: 0...5) }
}

struct ModuleContent: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: String // e.g., "Video" or "Reading"
}

struct Module: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let content: [ModuleContent]
    let quiz: Quiz?
}

struct QuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let answers: [String]
    let correctAnswer: Int // Index of the correct answer
    let explanation: String
}

struct Quiz: Identifiable, Hashable {
    let id = UUID()
    let title: String
    var questions: [QuizQuestion]
}

enum CourseCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case core = "Core Skills"
    case advanced = "Advanced"
    case situational = "Situational"
    
    var id: String { self.rawValue }
}

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

// MARK: - Weekly Goals Section with new functionality

struct WeeklyGoalsSectionView: View {
    @State private var goals: [Goal] = [
        .init(title: "Smooth Acceleration", description: "Practice gradual acceleration from stops", detailedTip: "From a complete stop, imagine there is a full cup of water on your dashboard. Try to accelerate smoothly enough that it wouldn't spill. Count to 3 in your head as you press the accelerator.", whyItMatters: "Smooth acceleration improves fuel economy by up to 15% and reduces wear and tear on the engine and transmission. It also provides a more comfortable ride for passengers.", progress: 18, target: 25, color: .cyan),
        .init(title: "Speed Management", description: "Maintain speed within 5mph of limit", detailedTip: "Pay close attention to posted speed limit signs. On roads with changing limits, practice adjusting your speed before you enter the new zone.", whyItMatters: "Speeding is a leading cause of accidents. Maintaining a safe, legal speed gives you more time to react to unexpected hazards and reduces the severity of potential collisions.", progress: 35, target: 50, color: .orange),
        .init(title: "Complete Stops", description: "Perform full 3-second stops at all signs", detailedTip: "At a stop sign, come to a full stop where you feel no forward motion. Silently say 'one-thousand-one, one-thousand-two, one-thousand-three' before proceeding.", whyItMatters: "Rolling stops are illegal and dangerous. A full stop gives you time to accurately check for cross-traffic, pedestrians, and cyclists before entering an intersection.", progress: 38, target: 40, color: .red),
        .init(title: "Following Distance", description: "Maintain a 3-second gap", detailedTip: "When the car ahead of you passes a fixed object (like a sign), start counting. If you reach the object before you count to three, you're too close.", whyItMatters: "This is the single most effective way to prevent rear-end collisions. A 3-second gap provides the necessary time and distance to perceive a hazard and brake safely.", progress: 28, target: 40, color: .purple)
    ]
    
    @State private var selectedGoal: Goal?
    @State private var showGoalDetail = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("This Week's Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    Button(action: {
                        selectedGoal = goal
                        showGoalDetail = true
                    }) {
                       GoalCard(goal: goal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .sheet(isPresented: $showGoalDetail) {
            if let selectedGoal, let index = goals.firstIndex(where: { $0.id == selectedGoal.id }) {
                GoalDetailView(goal: $goals[index])
            }
        }
    }
}

struct GoalCard: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text("\(goal.progress)/\(goal.target) drives")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Text(goal.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            ProgressView(value: Double(goal.progress), total: Double(goal.target))
                .progressViewStyle(LinearProgressViewStyle(tint: goal.color))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GoalDetailView: View {
    @Binding var goal: Goal
    @Environment(\.dismiss) var dismiss
    @State private var showCourseAlert = false
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))

    var body: some View {
        ZStack {
            deepBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                HStack {
                    Text(goal.title)
                        .font(.largeTitle).fontWeight(.bold)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 20) {
                        ProgressView(value: Double(goal.progress), total: Double(goal.target))
                            .progressViewStyle(LinearProgressViewStyle(tint: goal.color))
                            .scaleEffect(y: 2)
                            .animation(.easeInOut, value: goal.progress)

                        HStack {
                            Text("Current Progress: \(goal.progress) / \(goal.target) drives")
                            Spacer()
                        }
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                        PracticeHistoryChartView(goal: goal)
                        
                        InfoCard(title: "Pro Tip", text: goal.detailedTip, icon: "lightbulb.fill", iconColor: goal.color)
                        InfoCard(title: "Why This Matters", text: goal.whyItMatters, icon: "exclamationmark.shield.fill", iconColor: .yellow)
                        
                        Button(action: { showCourseAlert = true }) {
                            HStack {
                                Text("Find Related Courses")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue.opacity(0.5))
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    if goal.progress < goal.target {
                        withAnimation {
                            goal.progress += 1
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Log a Practice Session")
                    }
                    .font(.headline).bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(goal.progress < goal.target ? Color.green : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(goal.progress >= goal.target)
                .animation(.default, value: goal.progress)
            }
            .foregroundColor(.white)
            .padding()
            .alert("Find Courses", isPresented: $showCourseAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("To find courses related to '\(goal.title)', go to the Courses tab and use the search bar.")
            }
        }
    }
}

struct PracticeHistoryChartView: View {
    let goal: Goal
    let days = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days Practice")
                .font(.title2).bold()
            
            HStack(spacing: 10) {
                ForEach(0..<7) { i in
                    VStack {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 100)
                            
                            if goal.practiceHistory[i] > 0 {
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(goal.color)
                                    .frame(height: CGFloat(goal.practiceHistory[i]) * 20.0)
                            }
                        }
                        Text(days[i])
                            .font(.caption).bold()
                    }
                }
            }
            .animation(.easeInOut, value: goal.practiceHistory)
        }
    }
}

struct InfoCard: View {
    let title: String
    let text: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2).fontWeight(.bold)
                Text(title)
                    .font(.title2).fontWeight(.bold)
            }
            .foregroundColor(iconColor)
            
            Text(text)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}


// MARK: - Drive History Section
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

// MARK: - Courses Section
struct CoursesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCourse: Course?
    @State private var searchText = ""
    @State private var selectedCategory: CourseCategory = .all
    
    let courses: [Course] = Course.allCourses
    
    var filteredCourses: [Course] {
        let categoryFiltered = (selectedCategory == .all) ? courses : courses.filter { $0.category == selectedCategory }
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.description.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1)).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Driving Courses")
                            .font(.largeTitle).fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Unlock new skills and improve safety")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }.padding([.horizontal, .top])
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(CourseCategory.allCases) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category.rawValue)
                                        .font(.subheadline).bold()
                                        .foregroundColor(selectedCategory == category ? .black : .white)
                                        .padding(.horizontal, 16).padding(.vertical, 8)
                                        .background(selectedCategory == category ? .yellow : Color.white.opacity(0.1))
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            if !filteredCourses.isEmpty && selectedCategory == .all && searchText.isEmpty {
                                let featured = courses.first!
                                Text("Featured Course")
                                    .font(.title2).bold().foregroundColor(.white).padding(.horizontal)
                                CourseCard(course: featured)
                                    .onTapGesture { selectedCourse = featured }
                                    .padding(.horizontal)
                            }

                            Text(selectedCategory.rawValue)
                                .font(.title2).bold().foregroundColor(.white).padding(.horizontal)

                            if filteredCourses.isEmpty {
                                Text("No courses found for '\(searchText)'")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding()
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                                    ForEach(filteredCourses) { course in
                                        CourseCard(course: course)
                                            .onTapGesture { selectedCourse = course }
                                    }
                                }.padding(.horizontal)
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationBarHidden(true)
            .searchable(text: $searchText, prompt: "Search for a course")
            .sheet(item: $selectedCourse) { course in
                CourseContentView(course: course)
            }
        }
    }
}


struct Course: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let category: CourseCategory
    let imageName: String
    let modules: [Module]
    
    var duration: String {
        let totalQuizzes = modules.filter { $0.quiz != nil }.count
        if totalQuizzes > 0 {
            return "\(totalQuizzes) \(totalQuizzes == 1 ? "Quiz" : "Quizzes")"
        } else if !modules.isEmpty {
            return "\(modules.count) Modules"
        } else {
            return "Info Only"
        }
    }
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                course.color
                Image(systemName: course.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.2))
                    .offset(x: 20, y: -10)
            }
            .frame(height: 100)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(course.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                Text(course.duration)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(course.color)
            }
            .padding([.horizontal, .bottom], 12)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct CourseContentView: View {
    let course: Course
    @Environment(\.dismiss) var dismiss
    @State private var selectedModule: Module?
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))
    
    var body: some View {
        ZStack {
            deepBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ZStack {
                    Image(systemName: course.imageName)
                        .font(.system(size: 150))
                        .foregroundColor(course.color.opacity(0.3))
                        .offset(y: -20)
                    
                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, deepBlue], startPoint: .top, endPoint: .bottom))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text(course.title)
                            .font(.largeTitle).bold()
                        Text(course.description)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                .frame(height: 200)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if course.modules.isEmpty {
                             Text("Content for this course is coming soon.")
                                 .font(.headline)
                                 .foregroundColor(.white.opacity(0.7))
                                 .padding()
                                 .frame(maxWidth: .infinity)
                         } else {
                             ForEach(course.modules) { module in
                                 ModuleSectionView(module: module) {
                                     selectedModule = module
                                 }
                             }
                         }
                    }
                    .padding()
                }
            }
            .foregroundColor(.white)
            .edgesIgnoringSafeArea(.top)
            .sheet(item: $selectedModule) { module in
                if let quiz = module.quiz {
                    QuizView(quiz: quiz)
                }
            }
        }
    }
}

struct ModuleSectionView: View {
    let module: Module
    let onTakeQuiz: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(module.title)
                .font(.title2).bold()
                .padding(.top)
            
            ForEach(module.content) { content in
                ModuleContentRow(content: content)
            }
            
            if module.quiz != nil {
                Button(action: onTakeQuiz) {
                    HStack {
                        Spacer()
                        Text("Take Module Quiz")
                        Image(systemName: "arrow.right.circle.fill")
                        Spacer()
                    }
                    .font(.headline).bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
    }
}

struct ModuleContentRow: View {
    let content: ModuleContent
    @State private var showAlert = false

    var icon: String {
        switch content.type {
        case "Video": return "play.rectangle.fill"
        case "Reading": return "book.fill"
        default: return "questionmark.diamond.fill"
        }
    }
    
    var body: some View {
        Button(action: { showAlert = true }) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 30)
                
                Text(content.title)
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Content not available", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This feature is not yet implemented.")
        }
    }
}


struct QuizView: View {
    @State var quiz: Quiz
    @Environment(\.dismiss) var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int?
    @State private var score = 0
    @State private var showResult = false

    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1)).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if showResult {
                    QuizResultView(score: score, total: quiz.questions.count, onDismiss: { dismiss() })
                } else {
                    let question = quiz.questions[currentQuestionIndex]
                    
                    Text(quiz.title)
                        .font(.largeTitle).bold()
                    
                    Text("Question \(currentQuestionIndex + 1) of \(quiz.questions.count)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))

                    VStack(alignment: .leading, spacing: 16) {
                        Text(question.text)
                            .font(.title2).fontWeight(.medium)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        ForEach(0..<question.answers.count, id: \.self) { index in
                            AnswerButton(
                                text: question.answers[index],
                                isSelected: selectedAnswerIndex == index,
                                selectionState: getSelectionState(for: index, correctAnswer: question.correctAnswer)
                            ) {
                                if selectedAnswerIndex == nil {
                                    selectedAnswerIndex = index
                                    if index == question.correctAnswer {
                                        score += 1
                                    }
                                }
                            }
                        }
                        
                        if selectedAnswerIndex != nil {
                             Text(question.explanation)
                                 .font(.caption)
                                 .padding(12)
                                 .background(Color.white.opacity(0.1))
                                 .cornerRadius(8)
                                 .transition(.opacity.animation(.easeIn))
                         }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    
                    if selectedAnswerIndex != nil {
                        Button(action: nextQuestion) {
                            Text(currentQuestionIndex == quiz.questions.count - 1 ? "Finish Quiz" : "Next Question")
                                .font(.headline).bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                    }
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .padding()
        }
    }
    
    func getSelectionState(for index: Int, correctAnswer: Int) -> AnswerButton.SelectionState {
        guard let selectedAnswerIndex = selectedAnswerIndex else {
            return .unselected
        }
        if index == correctAnswer {
            return .correct
        }
        if index == selectedAnswerIndex {
            return .incorrect
        }
        return .unselected
    }

    func nextQuestion() {
        if currentQuestionIndex < quiz.questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
        } else {
            showResult = true
        }
    }
}

struct AnswerButton: View {
    enum SelectionState { case unselected, correct, incorrect }
    
    let text: String
    let isSelected: Bool
    let selectionState: SelectionState
    let action: () -> Void
    
    var backgroundColor: Color {
        switch selectionState {
        case .unselected: return Color.white.opacity(0.2)
        case .correct: return .green
        case .incorrect: return .red
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                Spacer()
                if isSelected {
                    Image(systemName: selectionState == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
            )
        }
        .animation(.default, value: selectionState)
    }
}

struct QuizResultView: View {
    let score: Int
    let total: Int
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Quiz Complete!")
                .font(.largeTitle).bold()
            
            Text("Your Score")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(score) / \(total)")
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(Double(score) / Double(total) >= 0.7 ? .green : .orange)
            
            Text(score == total ? "Perfect! Great job." : "Good effort! Review the material and try again.")
                .font(.headline)
            
            Button(action: onDismiss) {
                Text("Done")
                    .font(.headline).bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
    }
}


// MARK: - ENHANCED AI Recommendations View

struct AIDetailedRecommendationsView: View {
    let student: Kid
    @Environment(\.presentationMode) var presentationMode
    
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))
    
    var body: some View {
        NavigationView {
            ZStack {
                deepBlue.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(spacing: 30) {
                        VStack(spacing: 4) {
                            Text("AI-Powered Insights")
                                .font(.largeTitle).fontWeight(.bold)
                            Text("Analysis for \(student.name)")
                                .font(.headline).fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .foregroundColor(.white)
                        .padding(.top)

                        // AI Summary Text Block
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .font(.title2)
                                Text("AI Summary")
                                    .font(.title2).bold()
                            }
                            .foregroundColor(.yellow)
                            
                            Text("Overall, **\(student.name)** is demonstrating solid progress and a commitment to safe driving, reflected in a strong 'Control' score of **\(student.driveHistory.first?.performanceBreakdown.control ?? 0)**. Their ability to manage following distance is also a key strength.")
                                .padding(.bottom, 4)
                            
                            Text("The primary area for improvement is **Speed Management**, which is currently the lowest-scoring performance metric. The data indicates that most speeding instances occur on the highway bypass during afternoon hours. Additionally, we've noted **\(student.metrics.hardBraking) hard braking events** this week, which often happen in stop-and-go traffic during the morning rush hour. Focusing on smoother braking and better speed awareness will significantly boost the overall safety rating.")
                        }
                        .font(.body)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)

                        if let breakdown = student.driveHistory.first?.performanceBreakdown {
                            PerformanceBreakdownView(breakdown: breakdown)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Key Insights")
                                .font(.title2).bold().foregroundColor(.white).padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    InsightPillView(icon: "clock.arrow.circlepath", text: "Most incidents occur during morning rush hour (7-8 AM).")
                                    InsightPillView(icon: "mappin.and.ellipse", text: "Speeding is most common on the highway bypass.")
                                    InsightPillView(icon: "car.2.fill", text: "Hard braking often follows periods of tailgating.")
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Focus Areas")
                                .font(.title2).bold().foregroundColor(.white)
                            
                            FocusAreaRowView(icon: "exclamationmark.triangle.fill", title: "Hard Braking", value: "\(student.metrics.hardBraking) events", trend: "+15%", trendColor: .red, recommendation: "Increase following distance for smoother stops.")
                            FocusAreaRowView(icon: "arrow.up.right", title: "Rapid Acceleration", value: "\(student.metrics.rapidAcceleration) events", trend: "-10%", trendColor: .green, recommendation: "Apply gentle, steady pressure to the accelerator.")
                            FocusAreaRowView(icon: "speedometer", title: "Speeding", value: "\(student.metrics.speedingInstances) instance", trend: "+5%", trendColor: .red, recommendation: "Stay aware of posted speed limits, especially in school zones.")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
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
}

struct InsightPillView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.yellow)
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.15))
        .cornerRadius(20)
    }
}

struct FocusAreaRowView: View {
    let icon: String
    let title: String
    let value: String
    let trend: String
    let trendColor: Color
    let recommendation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.orange)
                Text(title)
                    .font(.headline).bold()
                Spacer()
                Text(value)
                    .font(.headline).bold()
                HStack(spacing: 2) {
                    Image(systemName: trend.contains("+") ? "arrow.up.right" : "arrow.down.right")
                    Text(trend)
                }
                .font(.caption.bold())
                .foregroundColor(trendColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(trendColor.opacity(0.2))
                .cornerRadius(8)
            }
            Text(recommendation)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}


// MARK: - Other Unchanged Views

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
                            Text("Core Metrics")
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
                        
                        if let recentDrive = student.driveHistory.first {
                            VStack(spacing: 20) {
                                PerformanceBreakdownView(breakdown: recentDrive.performanceBreakdown)
                                ManeuverAnalysisListView(analyses: recentDrive.maneuverAnalyses)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
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


// MARK: - Quiz and Course Data
extension Quiz {
    static let defensiveDrivingM1Quiz = Quiz(title: "Defensive Driving M1", questions: [
        .init(text: "What does 'SIPDE' stand for?", answers: ["Stop, Indicate, Proceed, Direct, Exit", "Scan, Identify, Predict, Decide, Execute", "Speed, Inspect, Prepare, Drive, Engage", "Signal, Inspect, Pull, Depart, Enter"], correctAnswer: 1, explanation: "SIPDE is a 5-step process for defensive driving: Scan, Identify, Predict, Decide, and Execute."),
        .init(text: "An 'escape route' is:", answers: ["A shortcut", "The shoulder", "A path to avoid a collision", "A fast lane"], correctAnswer: 2, explanation: "An escape route is an open space you can move into to avoid a collision with a sudden hazard."),
        .init(text: "How far ahead should you scan the road in a city?", answers: ["1-2 seconds", "5-7 seconds", "12-15 seconds", "30 seconds"], correctAnswer: 2, explanation: "Scanning 12-15 seconds ahead (about one city block) gives you time to see and react to potential problems."),
        .init(text: "What is a primary principle of defensive driving?", answers: ["Always driving below the speed limit", "Maintaining a space cushion", "Only driving during daylight hours", "Never changing lanes"], correctAnswer: 1, explanation: "Maintaining a 'space cushion' on all sides of your vehicle gives you more time and space to react to the actions of other drivers."),
        .init(text: "If a vehicle's high beams are blinding you, you should look:", answers: ["Directly into the lights", "At the left side of the road", "Towards the right edge of your lane", "At your phone"], correctAnswer: 2, explanation: "Looking toward the white line on the right side of the road helps you stay in your lane without being blinded by oncoming glare.")
    ])
    
    static let defensiveDrivingM2Quiz = Quiz(title: "Defensive Driving M2", questions: [
        .init(text: "What is the '3-second rule' for?", answers: ["Parking", "Following distance", "Changing lanes", "Making a turn"], correctAnswer: 1, explanation: "The 3-second rule helps you maintain a safe following distance, giving you enough time to react to hazards."),
        .init(text: "You should increase your following distance when:", answers: ["Driving in sunny, clear weather", "A driver behind you is tailgating", "Following a small car", "You are in a hurry"], correctAnswer: 1, explanation: "If a driver is tailgating you, increasing your following distance from the car in front gives you more space to brake gradually, reducing the chance of the tailgater hitting you."),
        .init(text: "What is the safest way to handle a tailgater?", answers: ["Brake suddenly to warn them", "Speed up to create distance", "Slow down gradually or move over to let them pass", "Ignore them completely"], correctAnswer: 2, explanation: "Slowing down or moving over encourages the tailgater to pass you, which is the safest way to resolve the situation."),
        .init(text: "What is the primary purpose of a head check?", answers: ["To check your hair", "To look for traffic in your blind spot", "To see if your headlights are on", "To adjust the radio"], correctAnswer: 1, explanation: "A head check, or shoulder check, is essential for seeing vehicles in your blind spots, which are areas not visible in your mirrors."),
        .init(text: "If you start to skid, what is the first thing you should do?", answers: ["Slam on the brakes", "Turn the steering wheel in the opposite direction of the skid", "Take your foot off the gas and brake", "Close your eyes"], correctAnswer: 2, explanation: "Immediately take your feet off both the accelerator and the brake. Then, look and steer gently in the direction you want the car to go."),
    ])

    static let highwaySkillsM1Quiz = Quiz(title: "Highway Skills M1", questions: [
        .init(text: "When merging onto a highway, you should:", answers: ["Stop at the end of the ramp", "Slow down and wait for a gap", "Match the speed of traffic and find a gap", "Force your way into traffic"], correctAnswer: 2, explanation: "The entrance ramp is designed for you to accelerate to the speed of highway traffic. This allows you to merge smoothly and safely into an open gap."),
        .init(text: "A 'weave lane' is a lane that:", answers: ["Is reserved for weaving in and out of traffic", "Serves as both an entrance and an exit ramp", "Has a wavy, curved pattern", "Is for motorcycles only"], correctAnswer: 1, explanation: "A weave lane is a section of roadway where entering and exiting traffic share the same lane, requiring extra caution from all drivers."),
        .init(text: "If you miss your highway exit, you should:", answers: ["Stop and back up on the shoulder", "Make a U-turn from the median", "Proceed to the next exit", "Pull over and wait for help"], correctAnswer: 2, explanation: "It is extremely dangerous to stop or reverse on a highway. The only safe option is to continue to the next exit and find an alternate route."),
        .init(text: "The 'Move Over' law requires you to:", answers: ["Move over one lane when you see a pretty car", "Always drive in the right-most lane", "Slow down and move over a lane for stopped emergency vehicles", "Let faster cars pass you"], correctAnswer: 2, explanation: "The 'Move Over' law is a critical safety rule that requires drivers to slow down and, if possible, change lanes to give safe clearance to stopped emergency and service vehicles."),
        .init(text: "When traffic is merging, what is the best strategy?", answers: ["Speed up to get ahead of everyone", "Stop to let others go first", "Adjust your speed and lane position to allow for a smooth merge", "Ignore the merging traffic"], correctAnswer: 2, explanation: "Cooperative driving is key. Adjusting your own position and speed to create space for merging vehicles ensures a smoother and safer traffic flow for everyone."),
    ])
    
    static let highwaySkillsM2Quiz = Quiz(title: "Highway Skills M2", questions: [
        .init(text: "What is a 'blind spot'?", answers: ["An area blocked by your rearview mirror", "The area directly behind your car", "An area around your car not visible in your mirrors", "The spot you aim for when parking"], correctAnswer: 2, explanation: "Blind spots are areas to the sides of your car that cannot be seen in your mirrors. You must physically turn your head to check them before changing lanes."),
        .init(text: "When driving on a multi-lane highway, the left-most lane is generally for:", answers: ["Slower traffic and exiting", "All types of traffic", "Trucks and large vehicles", "Passing and faster-moving traffic"], correctAnswer: 3, explanation: "The left lane is typically intended for passing other vehicles. After passing, you should move back into the center or right lane to allow others to pass."),
        .init(text: "What is 'highway hypnosis'?", answers: ["A fear of driving on highways", "A trance-like state from driving long distances", "The feeling of speed when you exit a highway", "The bright glare from highway lights"], correctAnswer: 1, explanation: "Highway hypnosis is a state of reduced attention that can occur after long periods of monotonous driving. To prevent it, keep your eyes moving, take regular breaks, and stay engaged."),
        .init(text: "When should you move back into your lane after passing a large truck?", answers: ["As soon as you are past its front bumper", "When you can see both of its headlights in your rearview mirror", "After you have been in front of it for 10 seconds", "Whenever you feel like it"], correctAnswer: 1, explanation: "Waiting until you can see both of the truck's headlights ensures you have cleared its front end with enough space to move back safely without cutting it off."),
        .init(text: "What does a solid yellow line on your side of the road mean?", answers: ["Passing is allowed", "Passing is not allowed", "The road is ending", "You are in an express lane"], correctAnswer: 1, explanation: "A solid yellow line indicates that you may not pass vehicles in front of you. A broken yellow line allows passing when safe."),
    ])

    static let nightDrivingM1Quiz = Quiz(title: "Night Driving M1", questions: [
        .init(text: "When should you use your high-beam headlights?", answers: ["On well-lit city streets", "In fog or heavy rain", "On unlit rural roads with no other cars", "When another car is approaching"], correctAnswer: 2, explanation: "High beams should be used on dark, unlit roads to increase visibility, but you must dim them when you see another vehicle approaching."),
        .init(text: "To reduce glare from oncoming headlights, you should look:", answers: ["Directly at the headlights", "At the center line of the road", "Towards the right edge of your lane", "At your dashboard"], correctAnswer: 2, explanation: "Looking toward the white line on the right side of the road helps you stay in your lane without being blinded by oncoming glare."),
        .init(text: "Why is driving at night more dangerous?", answers: ["Reduced visibility", "More tired drivers on the road", "Difficulty judging speed and distance", "All of the above"], correctAnswer: 3, explanation: "All these factors contribute to the increased risk of driving at night. Your vision is limited, and both you and other drivers may be more fatigued."),
        .init(text: "If an animal runs in front of your car at night, you should first:", answers: ["Swerve to avoid it", "Honk your horn loudly", "Brake firmly but safely", "Speed up to get past it"], correctAnswer: 2, explanation: "Your first reaction should be to brake safely. Swerving can cause you to lose control of your vehicle or drive into oncoming traffic, which is often more dangerous than hitting the animal."),
        .init(text: "You should dim your high beams when you are within ____ feet of an oncoming vehicle.", answers: ["100", "300", "500", "1000"], correctAnswer: 2, explanation: "Standard traffic laws require you to dim your high beams within 500 feet of an oncoming vehicle to avoid blinding the other driver."),
    ])
    
    static let parkingProM1Quiz = Quiz(title: "Parking Pro M1", questions: [
        .init(text: "When parking uphill with a curb, you should turn your wheels:", answers: ["Towards the curb", "Away from the curb", "Straight", "It doesn't matter"], correctAnswer: 1, explanation: "Turn your wheels away from the curb. If your car rolls, it will roll into the curb and stop."),
        .init(text: "When parking downhill with a curb, you should turn your wheels:", answers: ["Towards the curb", "Away from the curb", "Straight", "It doesn't matter"], correctAnswer: 0, explanation: "Turn your wheels towards the curb. If your car rolls, it will roll into the curb and stop."),
        .init(text: "When parking in an angled spot, you should approach:", answers: ["As close to the left side as possible", "From a wide angle to have a clear view", "Quickly", "In reverse"], correctAnswer: 1, explanation: "Approaching from a wide angle gives you the best visibility of the entire space and makes it easier to center your vehicle."),
    ])
    
    static let parkingProM2Quiz = Quiz(title: "Parking Pro M2", questions: [
        .init(text: "What is the first step in parallel parking?", answers: ["Turn the wheel all the way", "Pull up even with the car in front of the space", "Check your mirrors", "Honk your horn"], correctAnswer: 1, explanation: "The first step is to signal and pull up parallel to the car you will be parking behind, about 2-3 feet away."),
        .init(text: "When backing out of a parking space, you should:", answers: ["Only use your rearview mirror", "Look primarily over your right shoulder", "Turn your head and look back, while also checking mirrors", "Let your camera do all the work"], correctAnswer: 2, explanation: "You must physically look back while also checking all mirrors and your backup camera to ensure the path is completely clear."),
        .init(text: "What does a blue curb mean?", answers: ["Loading zone", "Fire lane", "Reserved for persons with disabilities", "Short-term parking"], correctAnswer: 2, explanation: "Blue curbs indicate parking spaces reserved for individuals with disabled parking permits."),
    ])

    static let weatherM1Quiz = Quiz(title: "Inclement Weather M1", questions: [
        .init(text: "What is hydroplaning?", answers: ["Driving a boat car", "When your tires lose contact with a wet road surface", "A type of car wash", "Driving through a puddle"], correctAnswer: 1, explanation: "Hydroplaning occurs when a layer of water builds between your tires and the road, causing a loss of traction and control."),
        .init(text: "If your car begins to hydroplane, you should:", answers: ["Slam on the brakes", "Accelerate quickly", "Ease your foot off the gas and steer straight", "Turn the steering wheel sharply"], correctAnswer: 2, explanation: "Do not brake or turn suddenly. Ease off the accelerator and keep the steering wheel straight until your tires regain traction."),
        .init(text: "In heavy fog, you should use your:", answers: ["High beams", "Low beams", "Parking lights only", "Hazard lights"], correctAnswer: 1, explanation: "High beams will reflect off the fog and worsen visibility. Low beams aim down at the road and are the correct choice."),
    ])

    // Other quizzes are filled with placeholder data for brevity but follow the same structure.
    static let cityDrivingM1Quiz = Quiz(title: "City Driving M1", questions: [])
    static let emergencyM1Quiz = Quiz(title: "Emergency M1", questions: [])
    static let roundaboutM1Quiz = Quiz(title: "Roundabouts M1", questions: [])
    static let maintenanceM1Quiz = Quiz(title: "Maintenance M1", questions: [])
    static let advancedTurnsM1Quiz = Quiz(title: "Advanced Turns M1", questions: [])
    static let distractionM1Quiz = Quiz(title: "Distractions M1", questions: [])
    static let ruralM1Quiz = Quiz(title: "Rural Roads M1", questions: [])
    static let roadTripM1Quiz = Quiz(title: "Road Trips M1", questions: [])
    static let postAccidentM1Quiz = Quiz(title: "Post-Accident M1", questions: [])
    static let ecoDrivingM1Quiz = Quiz(title: "Eco-Driving M1", questions: [])
    static let trafficLawsM1Quiz = Quiz(title: "Traffic Laws M1", questions: [])
    static let reverseParkingM1Quiz = Quiz(title: "Reverse Parking M1", questions: [])
    static let interstateM1Quiz = Quiz(title: "Interstate M1", questions: [])
    static let threePointTurnM1Quiz = Quiz(title: "3-Point Turns M1", questions: [])
    static let roadSignsM1Quiz = Quiz(title: "Road Signs M1", questions: [])
}

extension Course {
    static let allCourses: [Course] = [
        Course(title: "Defensive Driving", description: "Anticipate and avoid hazards", icon: "shield.checkered", color: .green, category: .core, imageName: "shield.lefthalf.filled", modules: [
            .init(title: "Module 1: Core Principles", content: [ .init(title: "The SIPDE System", type: "Video"), .init(title: "Identifying Escape Routes", type: "Reading") ], quiz: .defensiveDrivingM1Quiz),
            .init(title: "Module 2: Advanced Techniques", content: [ .init(title: "Mastering Following Distance", type: "Video"), .init(title: "Handling Tailgaters Safely", type: "Video") ], quiz: .defensiveDrivingM2Quiz)
        ]),
        Course(title: "Highway Skills", description: "Merging, lane changes, and more", icon: "road.lanes", color: .blue, category: .advanced, imageName: "road.lanes", modules: [
            .init(title: "Module 1: On-Ramps and Off-Ramps", content: [ .init(title: "Merging and Exiting at Speed", type: "Video") ], quiz: .highwaySkillsM1Quiz),
            .init(title: "Module 2: Lane Discipline", content: [ .init(title: "Blind Spot Checks", type: "Video"), .init(title: "Understanding Highway Hypnosis", type: "Reading") ], quiz: .highwaySkillsM2Quiz)
        ]),
        Course(title: "Night Driving", description: "Master driving in low light", icon: "moon.stars.fill", color: .purple, category: .situational, imageName: "moon.stars.fill", modules: [
            .init(title: "Module 1: Seeing and Being Seen", content: [ .init(title: "Using Your Headlights Correctly", type: "Video"), .init(title: "How to Handle Glare", type: "Reading") ], quiz: .nightDrivingM1Quiz)
        ]),
        Course(title: "Parking Pro", description: "Parallel, angled, and lot parking", icon: "parkingsign.circle.fill", color: .orange, category: .advanced, imageName: "parkingsign.circle.fill", modules: [
            .init(title: "Module 1: Lot Parking", content: [ .init(title: "Angled vs. Straight", type: "Video")], quiz: .parkingProM1Quiz),
            .init(title: "Module 2: Parallel Parking", content: [ .init(title: "Step-by-Step Guide", type: "Video")], quiz: .parkingProM2Quiz)
        ]),
        Course(title: "Inclement Weather", description: "Driving in rain, fog, and snow", icon: "cloud.rain.fill", color: .gray, category: .situational, imageName: "cloud.sleet.fill", modules: [
            .init(title: "Module 1: Driving in Rain", content: [ .init(title: "Hydroplaning Avoidance", type: "Video")], quiz: .weatherM1Quiz)
        ]),
        Course(title: "City Driving", description: "Navigate dense urban environments", icon: "building.2.fill", color: .pink, category: .situational, imageName: "building.columns.fill", modules: [
            .init(title: "Module 1: Urban Challenges", content: [ .init(title: "One-Way Streets and Pedestrians", type: "Video")], quiz: .cityDrivingM1Quiz)
        ]),
        Course(title: "Emergency Maneuvers", description: "Reacting to sudden events", icon: "exclamationmark.triangle.fill", color: .red, category: .advanced, imageName: "figure.walk.diamond.fill", modules: [
            .init(title: "Module 1: Evasive Actions", content: [ .init(title: "Skid Control", type: "Video")], quiz: .emergencyM1Quiz)
        ]),
        Course(title: "Roundabout Navigation", description: "Mastering traffic circles with ease", icon: "arrow.triangle.swap", color: .teal, category: .advanced, imageName: "arrow.triangle.turn.up.right.circle.fill", modules: [
            .init(title: "Module 1: Roundabout Rules", content: [ .init(title: "Yielding and Lane Choice", type: "Video")], quiz: .roundaboutM1Quiz)
        ]),
        Course(title: "Vehicle Maintenance 101", description: "Basic checks to keep your car safe", icon: "wrench.and.screwdriver.fill", color: .gray, category: .core, imageName: "gearshape.2.fill", modules: [
            .init(title: "Module 1: Fluid and Tire Checks", content: [ .init(title: "Checking Tire Pressure", type: "Video")], quiz: .maintenanceM1Quiz)
        ]),
        Course(title: "Advanced Turns", description: "Perfecting U-turns and three-point turns", icon: "arrow.uturn.backward.circle", color: .indigo, category: .advanced, imageName: "arrow.uturn.backward.square.fill", modules: [
             .init(title: "Module 1: The Three-Point Turn", content: [ .init(title: "When and How to Execute", type: "Video")], quiz: .advancedTurnsM1Quiz)
        ]),
        Course(title: "Distraction Avoidance", description: "Techniques to stay focused on the road", icon: "iphone.slash", color: .mint, category: .core, imageName: "phone.down.waves.left.and.right", modules: [
            .init(title: "Module 1: Identifying Distractions", content: [ .init(title: "Cognitive, Visual, and Manual", type: "Reading")], quiz: .distractionM1Quiz)
        ]),
        Course(title: "Rural Road Safety", description: "Handling wildlife and unpaved roads", icon: "camera.macro", color: Color(red: 0.6, green: 0.4, blue: 0.2), category: .situational, imageName: "ladybug.fill", modules: [
            .init(title: "Module 1: Unexpected Encounters", content: [ .init(title: "Wildlife and Livestock on Roads", type: "Video")], quiz: .ruralM1Quiz)
        ]),
        Course(title: "Road Trip Prep", description: "Long-distance driving strategies", icon: "map.fill", color: .cyan, category: .advanced, imageName: "map.fill", modules: [
            .init(title: "Module 1: Planning Your Trip", content: [ .init(title: "Vehicle Checks and Route Planning", type: "Reading")], quiz: .roadTripM1Quiz)
        ]),
        Course(title: "Post-Accident Procedure", description: "What to do after a minor collision", icon: "person.text.rectangle.fill", color: .red, category: .situational, imageName: "person.text.rectangle.fill", modules: [
             .init(title: "Module 1: At the Scene", content: [ .init(title: "Staying Safe and Exchanging Info", type: "Video")], quiz: .postAccidentM1Quiz)
        ]),
        Course(title: "Eco-Driving", description: "Save fuel and reduce emissions", icon: "leaf.arrow.circlepath", color: .green, category: .core, imageName: "fuelpump.fill", modules: [
             .init(title: "Module 1: Efficient Habits", content: [ .init(title: "Maximizing Your MPG", type: "Reading")], quiz: .ecoDrivingM1Quiz)
        ]),
        Course(title: "Traffic Laws & Signs", description: "Understand the rules of the road", icon: "signpost.right.fill", color: .blue, category: .core, imageName: "signpost.and.arrowtriangle.up.fill", modules: [
            .init(title: "Module 1: Common Regulations", content: [ .init(title: "Right-of-Way Rules", type: "Video")], quiz: .trafficLawsM1Quiz)
        ]),
        Course(title: "Reverse Parking", description: "Backing into spaces safely", icon: "car.side.arrow.left", color: .orange, category: .advanced, imageName: "arrow.down.left.topright.rectangle.fill", modules: [
            .init(title: "Module 1: Backing-In Techniques", content: [ .init(title: "Using Mirrors and Cameras", type: "Video")], quiz: .reverseParkingM1Quiz)
        ]),
        Course(title: "Interstate Driving", description: "High-speed, long-distance travel", icon: "road.lanes.curved.right", color: .indigo, category: .advanced, imageName: "road.lanes", modules: [
            .init(title: "Module 1: Interstate Essentials", content: [ .init(title: "Managing High Speeds", type: "Video")], quiz: .interstateM1Quiz)
        ]),
        Course(title: "Three-Point Turns", description: "Turning around in tight spaces", icon: "arrow.3.trianglepath", color: .teal, category: .advanced, imageName: "arrow.3.trianglepath", modules: [
            .init(title: "Module 1: The K-Turn", content: [ .init(title: "Executing a Three-Point Turn", type: "Video")], quiz: .threePointTurnM1Quiz)
        ]),
        Course(title: "Understanding Road Signs", description: "Regulatory, Warning, and Guide Signs", icon: "signpost.left.fill", color: .gray, category: .core, imageName: "signpost.left.fill", modules: [
            .init(title: "Module 1: The Three Types of Signs", content: [ .init(title: "What Do The Colors and Shapes Mean?", type: "Reading")], quiz: .roadSignsM1Quiz)
        ])
    ]
}
