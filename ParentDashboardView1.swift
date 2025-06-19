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
                            
                            // NEW: AI Recommended Courses Section
                            AIRecommendedCoursesView(student: currentStudent)
                                .padding(.horizontal)
                            
                            // MODIFIED: Pass a binding to the selected student's goals
                            WeeklyGoalsSectionView(goals: $appData.kids[selectedStudent].goals, onShowCourses: { showCourses = true })
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
                // Pass the parent role and selected student to the CoursesView
                CoursesView(userRole: .parent, selectedStudentIndex: selectedStudent)
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

// MARK: - NEW AI Recommended Courses View
struct AIRecommendedCoursesView: View {
    let student: Kid
    @State private var selectedCourse: Course? = nil
    
    private var recommendedCourses: [Course] {
        Course.allCourses.filter { course in
            student.aiRecommendedCourseIDs.contains(course.id)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .foregroundColor(.yellow)
                Text("Recommended For \(student.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 8)
            
            if recommendedCourses.isEmpty {
                Text("No specific recommendations at this time. Great job!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(recommendedCourses) { course in
                            CourseCard(course: course)
                                .frame(width: 180)
                                .onTapGesture { selectedCourse = course }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedCourse) { course in
            CourseContentView(course: course)
        }
    }
}


// MARK: - Weekly Goals Section with new functionality

struct WeeklyGoalsSectionView: View {
    @Binding var goals: [Goal]
    @State private var selectedGoal: Goal?
    @State private var showGoalDetail = false
    var onShowCourses: (() -> Void)? = nil // Add optional callback

    var body: some View {
        VStack(alignment: .leading) {
            Text("This Week's Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            if goals.isEmpty {
                Text("No weekly goals have been set for this student.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
            } else {
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
        }
        .sheet(isPresented: $showGoalDetail) {
            if let selectedGoal, let index = goals.firstIndex(where: { $0.id == selectedGoal.id }) {
                GoalDetailView(goal: $goals[index], onShowCourses: {
                    showGoalDetail = false
                    onShowCourses?()
                })
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
    var onShowCourses: (() -> Void)? = nil // Add optional callback
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
                        Button(action: {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                onShowCourses?()
                            }
                        }) {
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

// MARK: - Courses Section (MODIFIED)
struct CoursesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appData: AppData
    @State private var selectedCourse: Course?
    @State private var searchText = ""
    @State private var selectedCategory: CourseCategory = .all
    
    // Properties to handle different user roles
    let userRole: UserRole
    let selectedStudentIndex: Int?
    
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
                                
                                CourseTileView(
                                    course: featured,
                                    userRole: userRole,
                                    selectedStudentIndex: selectedStudentIndex,
                                    onTap: { selectedCourse = featured }
                                )
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
                                        CourseTileView(
                                            course: course,
                                            userRole: userRole,
                                            selectedStudentIndex: selectedStudentIndex,
                                            onTap: { selectedCourse = course }
                                        )
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

// NEW View to wrap CourseCard and add Recommend button
struct CourseTileView: View {
    @EnvironmentObject var appData: AppData
    
    let course: Course
    let userRole: UserRole
    let selectedStudentIndex: Int?
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            CourseCard(course: course)
                .onTapGesture(perform: onTap)
            
            if userRole == .parent, let studentIndex = selectedStudentIndex {
                let student = appData.kids[studentIndex]
                let isRecommended = student.parentRecommendedCourseIDs.contains(course.id)
                
                Button(action: {
                    // This is where we will modify the appData
                    withAnimation {
                        if isRecommended {
                            appData.kids[studentIndex].parentRecommendedCourseIDs.removeAll { $0 == course.id }
                        } else {
                            appData.kids[studentIndex].parentRecommendedCourseIDs.append(course.id)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isRecommended ? "checkmark.circle.fill" : "star.circle")
                        Text(isRecommended ? "Recommended" : "Recommend")
                    }
                    .font(.caption.bold())
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(isRecommended ? Color.green : Color.blue)
                    .foregroundColor(.white)
                }
                .padding(.top, 4)
                .background(.ultraThinMaterial) // Match the card background
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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
                            
                            FocusAreaRowView(icon: "exclamationmark.triangle.fill", title: "Hard Braking", value: "\(student.metrics.hardBraking) events", recommendation: "Increase following distance for smoother stops.")
                            FocusAreaRowView(icon: "arrow.up.right", title: "Rapid Acceleration", value: "\(student.metrics.rapidAcceleration) events", recommendation: "Apply gentle, steady pressure to the accelerator.")
                            FocusAreaRowView(icon: "speedometer", title: "Speeding", value: "\(student.metrics.speedingInstances) instance", recommendation: "Stay aware of posted speed limits, especially in school zones.")
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
    let recommendation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.orange)
                Text(title)
                    .font(.headline).bold()
                    .foregroundColor(.white)
                Spacer()
                Text(value)
                    .font(.headline).bold()
                    .foregroundColor(.white)
            }
            Text(recommendation)
                .font(.caption)
                .foregroundColor(.white)
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

    static let defensiveDrivingM3Quiz = Quiz(title: "Defensive Driving M3", questions: [
        .init(text: "What is the most important defensive driving principle?", answers: ["Always drive fast", "Anticipate the actions of others", "Never change lanes", "Always use cruise control"], correctAnswer: 1, explanation: "Anticipating the actions of other drivers is the core principle of defensive driving. Always expect the unexpected."),
        .init(text: "When should you use your horn defensively?", answers: ["To express frustration", "To alert others of your presence", "To make others move faster", "Never"], correctAnswer: 1, explanation: "Use your horn to alert others of your presence, not to express frustration or hurry others."),
        .init(text: "What is the best way to handle road rage?", answers: ["Respond in kind", "Ignore it completely", "Stay calm and avoid confrontation", "Call the police immediately"], correctAnswer: 2, explanation: "Stay calm and avoid confrontation. Don't engage with aggressive drivers - it only escalates the situation."),
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

    static let highwaySkillsM3Quiz = Quiz(title: "Highway Skills M3", questions: [
        .init(text: "What should you do if you break down on the highway?", answers: ["Stay in your car", "Get out and walk", "Move to the shoulder and call for help", "Try to fix it yourself"], correctAnswer: 2, explanation: "Move to the shoulder, turn on your hazard lights, and call for help. Stay in your car unless it's unsafe."),
        .init(text: "When driving on a highway at night, you should:", answers: ["Use your high beams always", "Use your low beams and watch for animals", "Turn off your headlights", "Use only parking lights"], correctAnswer: 1, explanation: "Use your low beams and be extra alert for animals that may cross the highway at night."),
        .init(text: "What is the safest speed to drive on a highway?", answers: ["The speed limit", "10 mph below the limit", "The flow of traffic", "Whatever feels comfortable"], correctAnswer: 2, explanation: "Drive with the flow of traffic, but never exceed the speed limit. Driving much slower than traffic can be dangerous."),
    ])

    static let nightDrivingM1Quiz = Quiz(title: "Night Driving M1", questions: [
        .init(text: "When should you use your high-beam headlights?", answers: ["On well-lit city streets", "In fog or heavy rain", "On unlit rural roads with no other cars", "When another car is approaching"], correctAnswer: 2, explanation: "High beams should be used on dark, unlit roads to increase visibility, but you must dim them when you see another vehicle approaching."),
        .init(text: "To reduce glare from oncoming headlights, you should look:", answers: ["Directly at the headlights", "At the center line of the road", "Towards the right edge of your lane", "At your dashboard"], correctAnswer: 2, explanation: "Looking toward the white line on the right side of the road helps you stay in your lane without being blinded by oncoming glare."),
        .init(text: "Why is driving at night more dangerous?", answers: ["Reduced visibility", "More tired drivers on the road", "Difficulty judging speed and distance", "All of the above"], correctAnswer: 3, explanation: "All these factors contribute to the increased risk of driving at night. Your vision is limited, and both you and other drivers may be more fatigued."),
        .init(text: "If an animal runs in front of your car at night, you should first:", answers: ["Swerve to avoid it", "Honk your horn loudly", "Brake firmly but safely", "Speed up to get past it"], correctAnswer: 2, explanation: "Your first reaction should be to brake safely. Swerving can cause you to lose control of your vehicle or drive into oncoming traffic, which is often more dangerous than hitting the animal."),
        .init(text: "You should dim your high beams when you are within ____ feet of an oncoming vehicle.", answers: ["100", "300", "500", "1000"], correctAnswer: 2, explanation: "Standard traffic laws require you to dim your high beams within 500 feet of an oncoming vehicle to avoid blinding the other driver."),
    ])
    
    static let nightDrivingM2Quiz = Quiz(title: "Night Driving M2", questions: [
        .init(text: "How can you improve your night vision?", answers: ["Wear sunglasses", "Look directly at oncoming lights", "Keep your eyes moving", "Close one eye"], correctAnswer: 2, explanation: "Keep your eyes moving and scan the road ahead. Don't stare at any one point for too long."),
        .init(text: "What should you do if you become drowsy while driving at night?", answers: ["Turn up the radio", "Open the window", "Pull over and rest", "Drink coffee"], correctAnswer: 2, explanation: "If you become drowsy, pull over to a safe location and rest. Don't try to fight fatigue while driving."),
        .init(text: "When should you use your high beams at night?", answers: ["Always", "Only on unlit roads with no oncoming traffic", "Only in the city", "Never"], correctAnswer: 1, explanation: "Use high beams only on unlit roads when there's no oncoming traffic. Dim them for oncoming vehicles."),
    ])

    static let nightDrivingM3Quiz = Quiz(title: "Night Driving M3", questions: [
        .init(text: "What is the most dangerous time to drive at night?", answers: ["Early evening", "Late night/early morning", "Midnight", "Dawn"], correctAnswer: 1, explanation: "Late night and early morning hours are most dangerous due to fatigue, impaired drivers, and reduced visibility."),
        .init(text: "How should you handle curves at night?", answers: ["Speed up to get through quickly", "Slow down and use your low beams", "Use your high beams", "Close your eyes"], correctAnswer: 1, explanation: "Slow down for curves at night and use your low beams to avoid blinding oncoming drivers."),
        .init(text: "What should you do if your headlights fail at night?", answers: ["Continue driving slowly", "Pull over immediately", "Use your high beams", "Turn on your hazard lights"], correctAnswer: 1, explanation: "If your headlights fail at night, pull over immediately. Driving without headlights is extremely dangerous."),
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

    static let parkingProM3Quiz = Quiz(title: "Parking Pro M3", questions: [
        .init(text: "When parking on a hill, you should:", answers: ["Always turn your wheels toward the curb", "Always turn your wheels away from the curb", "Turn wheels based on whether you're facing uphill or downhill", "It doesn't matter"], correctAnswer: 2, explanation: "Turn your wheels based on whether you're facing uphill or downhill. This prevents your car from rolling into traffic."),
        .init(text: "What should you do before backing out of a parking space?", answers: ["Honk your horn", "Check for pedestrians and obstacles", "Turn on your hazard lights", "Speed up"], correctAnswer: 1, explanation: "Before backing, check for pedestrians, children, and obstacles in your path. Take your time and be thorough."),
        .init(text: "When parallel parking, you should:", answers: ["Get as close to the curb as possible", "Leave space between cars", "Park in the middle of the street", "Ignore parking regulations"], correctAnswer: 0, explanation: "When parallel parking, get as close to the curb as possible to avoid blocking traffic and to prevent other cars from hitting your vehicle."),
    ])

    static let weatherM1Quiz = Quiz(title: "Inclement Weather M1", questions: [
        .init(text: "What is hydroplaning?", answers: ["Driving a boat car", "When your tires lose contact with a wet road surface", "A type of car wash", "Driving through a puddle"], correctAnswer: 1, explanation: "Hydroplaning occurs when a layer of water builds between your tires and the road, causing a loss of traction and control."),
        .init(text: "If your car begins to hydroplane, you should:", answers: ["Slam on the brakes", "Accelerate quickly", "Ease your foot off the gas and steer straight", "Turn the steering wheel sharply"], correctAnswer: 2, explanation: "Do not brake or turn suddenly. Ease off the accelerator and keep the steering wheel straight until your tires regain traction."),
        .init(text: "In heavy fog, you should use your:", answers: ["High beams", "Low beams", "Parking lights only", "Hazard lights"], correctAnswer: 1, explanation: "High beams will reflect off the fog and worsen visibility. Low beams aim down at the road and are the correct choice."),
    ])

    static let weatherM2Quiz = Quiz(title: "Inclement Weather M2", questions: [
        .init(text: "When driving in snow, you should:", answers: ["Drive faster to avoid getting stuck", "Slow down and increase following distance", "Use cruise control", "Drive in the center of the road"], correctAnswer: 1, explanation: "In snow, slow down and increase your following distance. Snow reduces traction and increases stopping distance."),
        .init(text: "What should you do if you get stuck in snow?", answers: ["Spin your wheels to get out", "Rock your car back and forth gently", "Call for help immediately", "Get out and push"], correctAnswer: 1, explanation: "If stuck in snow, gently rock your car back and forth by shifting between drive and reverse. Don't spin your wheels as this digs you in deeper."),
        .init(text: "When driving on ice, you should:", answers: ["Brake normally", "Brake gently and early", "Brake hard at the last moment", "Not brake at all"], correctAnswer: 1, explanation: "On ice, brake gently and early. Sudden braking can cause you to lose control and skid."),
    ])

    static let weatherM3Quiz = Quiz(title: "Inclement Weather M3", questions: [
        .init(text: "What should you do if you encounter black ice?", answers: ["Speed up to get through quickly", "Slow down and avoid sudden movements", "Turn on your hazard lights", "Pull over immediately"], correctAnswer: 1, explanation: "Black ice is nearly invisible. Slow down and avoid sudden steering, braking, or acceleration movements."),
        .init(text: "In heavy rain, you should:", answers: ["Turn on your high beams", "Turn on your low beams", "Turn off your headlights", "Use only parking lights"], correctAnswer: 1, explanation: "In heavy rain, use your low beams. High beams can reflect off the rain and reduce visibility."),
        .init(text: "What is the most dangerous time to drive in winter weather?", answers: ["During the day", "At night", "During rush hour", "All of the above"], correctAnswer: 1, explanation: "Night driving in winter weather is most dangerous due to reduced visibility and colder temperatures that can cause ice to form more quickly."),
    ])

    // Other quizzes are filled with placeholder data for brevity but follow the same structure.
    static let cityDrivingM1Quiz = Quiz(title: "City Driving M1", questions: [
        .init(text: "When driving in a city, you should scan for hazards:", answers: ["Only when approaching intersections", "Every 2-3 seconds", "Only when changing lanes", "Only when pedestrians are present"], correctAnswer: 1, explanation: "In city driving, you should scan for hazards every 2-3 seconds due to the high density of potential conflicts and rapid changes in traffic conditions."),
        .init(text: "What should you do when approaching a one-way street?", answers: ["Speed up to get through quickly", "Look for the direction of traffic flow", "Ignore the signs", "Honk your horn"], correctAnswer: 1, explanation: "Always look for the direction of traffic flow on one-way streets. Look at the signs, traffic lights, and the direction other cars are parked."),
        .init(text: "When pedestrians are in a crosswalk, you must:", answers: ["Honk to warn them", "Speed up to get past quickly", "Stop and wait for them to cross", "Drive around them"], correctAnswer: 2, explanation: "You must stop and wait for pedestrians to completely cross the street when they are in a marked or unmarked crosswalk."),
        .init(text: "In heavy city traffic, you should maintain a following distance of:", answers: ["1-2 seconds", "2-3 seconds", "3-4 seconds", "4-5 seconds"], correctAnswer: 1, explanation: "In heavy city traffic, a 2-3 second following distance is appropriate, but be prepared to increase it if conditions worsen."),
        .init(text: "What is the best way to handle aggressive drivers in the city?", answers: ["Match their aggressive behavior", "Ignore them completely", "Stay calm and avoid confrontation", "Report them to the police immediately"], correctAnswer: 2, explanation: "The best response to aggressive drivers is to stay calm, avoid eye contact, and give them space. Don't engage in confrontational behavior.")
    ])
    
    static let cityDrivingM2Quiz = Quiz(title: "City Driving M2", questions: [
        .init(text: "When driving in heavy city traffic, you should:", answers: ["Change lanes frequently", "Stay in one lane when possible", "Use the shoulder to pass", "Honk at slow drivers"], correctAnswer: 1, explanation: "In heavy traffic, stay in one lane when possible. Frequent lane changes can cause accidents and slow down traffic flow."),
        .init(text: "What should you do when approaching a school zone?", answers: ["Speed up to get through quickly", "Slow down and watch for children", "Honk your horn", "Ignore the signs"], correctAnswer: 1, explanation: "Always slow down in school zones and watch for children who may dart into the street unexpectedly."),
        .init(text: "When parallel parking in the city, you should:", answers: ["Park as close to the curb as possible", "Leave space between cars", "Park in the middle of the street", "Ignore parking regulations"], correctAnswer: 0, explanation: "When parallel parking, get as close to the curb as possible to avoid blocking traffic and to prevent other cars from hitting your vehicle."),
    ])
    
    static let cityDrivingM3Quiz = Quiz(title: "City Driving M3", questions: [
        .init(text: "What should you do when approaching a construction zone?", answers: ["Speed up to get through quickly", "Slow down and follow worker directions", "Ignore the signs", "Use the opposite lane"], correctAnswer: 1, explanation: "Always slow down in construction zones and follow the directions of flaggers or workers. Construction zones often have reduced speed limits."),
        .init(text: "When driving in a city at night, you should:", answers: ["Use your high beams always", "Use your low beams and watch for pedestrians", "Turn off your headlights", "Use only parking lights"], correctAnswer: 1, explanation: "Use your low beams in the city at night and be extra alert for pedestrians who may be harder to see."),
        .init(text: "What is the most important thing to remember when driving in a city?", answers: ["Speed", "Patience and awareness", "Getting to your destination quickly", "Following other drivers"], correctAnswer: 1, explanation: "Patience and awareness are crucial in city driving. There are many potential hazards and you need to be alert and patient with other drivers and pedestrians."),
    ])
    
    static let emergencyM1Quiz = Quiz(title: "Emergency M1", questions: [
        .init(text: "If your brakes fail while driving, you should first:", answers: ["Pull the emergency brake immediately", "Downshift to a lower gear", "Turn off the engine", "Jump out of the car"], correctAnswer: 1, explanation: "If your brakes fail, first try downshifting to a lower gear to slow the vehicle. Then pump the brake pedal to see if you can restore pressure."),
        .init(text: "If your accelerator pedal gets stuck, you should:", answers: ["Turn off the engine immediately", "Shift to neutral and brake", "Jump out of the car", "Honk your horn continuously"], correctAnswer: 1, explanation: "If the accelerator gets stuck, shift to neutral to disengage the engine from the wheels, then apply the brakes to slow down safely."),
        .init(text: "What should you do if your car starts to skid?", answers: ["Slam on the brakes", "Turn the wheel in the direction of the skid", "Turn the wheel opposite to the skid", "Accelerate to regain control"], correctAnswer: 1, explanation: "In a skid, turn the steering wheel in the direction you want the car to go (the direction of the skid). Don't brake suddenly or overcorrect."),
        .init(text: "If your tire blows out while driving, you should:", answers: ["Brake hard immediately", "Steer straight and gradually slow down", "Turn the wheel sharply", "Accelerate to get off the road"], correctAnswer: 1, explanation: "If a tire blows out, grip the steering wheel firmly, steer straight, and gradually slow down. Don't brake suddenly as this can cause loss of control."),
        .init(text: "What is the first thing you should do if your car catches fire?", answers: ["Try to put out the fire", "Get everyone out of the car", "Call 911", "Open the hood to check the engine"], correctAnswer: 1, explanation: "If your car catches fire, the first priority is to get everyone out of the vehicle and move to a safe distance. Then call emergency services.")
    ])
    
    static let emergencyM2Quiz = Quiz(title: "Emergency M2", questions: [
        .init(text: "If your steering wheel becomes hard to turn, you should:", answers: ["Force it to turn", "Pull over immediately", "Speed up to get to a mechanic", "Ignore the problem"], correctAnswer: 1, explanation: "If your steering becomes hard to turn, pull over immediately. This could indicate a serious problem with your steering system."),
        .init(text: "What should you do if your headlights fail while driving at night?", answers: ["Continue driving slowly", "Pull over and stop", "Use your high beams", "Turn on your hazard lights"], correctAnswer: 1, explanation: "If your headlights fail at night, pull over and stop. Driving without headlights is extremely dangerous and illegal."),
        .init(text: "If your windshield wipers fail in the rain, you should:", answers: ["Continue driving", "Pull over and wait for the rain to stop", "Use your hand to wipe the windshield", "Speed up to get home"], correctAnswer: 1, explanation: "If your wipers fail in the rain, pull over and wait for the rain to stop or for help. Driving without visibility is dangerous."),
    ])
    
    static let emergencyM3Quiz = Quiz(title: "Emergency M3", questions: [
        .init(text: "What should you do if your car starts to overheat?", answers: ["Continue driving to get to a mechanic", "Pull over and turn off the engine", "Add water to the radiator immediately", "Turn on the heater"], correctAnswer: 1, explanation: "If your car overheats, pull over and turn off the engine. Let it cool down before checking the coolant level."),
        .init(text: "If you're involved in a minor accident with no injuries, you should:", answers: ["Leave the scene immediately", "Move vehicles out of traffic if possible", "Call the police immediately", "Exchange information and leave"], correctAnswer: 1, explanation: "If safe to do so, move vehicles out of traffic to prevent further accidents. Then exchange information with the other driver."),
        .init(text: "What should you do if you witness an accident?", answers: ["Stop and help if you can", "Continue driving", "Call 911 and continue driving", "Take photos and leave"], correctAnswer: 0, explanation: "If you witness an accident, stop and help if you can safely do so. Call 911 if emergency services are needed."),
    ])
    
    static let roundaboutM1Quiz = Quiz(title: "Roundabouts M1", questions: [
        .init(text: "When approaching a roundabout, you should:", answers: ["Speed up to get through quickly", "Slow down and yield to traffic already in the roundabout", "Honk your horn", "Ignore the yield signs"], correctAnswer: 1, explanation: "Always slow down when approaching a roundabout and yield to traffic already circulating in the roundabout."),
        .init(text: "In a roundabout, you should drive:", answers: ["Clockwise", "Counterclockwise", "Either direction", "In the middle"], correctAnswer: 1, explanation: "In the United States, roundabouts are designed for counterclockwise traffic flow. Always drive counterclockwise in a roundabout."),
        .init(text: "To exit a roundabout, you should:", answers: ["Signal right before your exit", "Signal left when entering", "Not signal at all", "Signal continuously"], correctAnswer: 0, explanation: "Signal right before your intended exit to let other drivers know you're leaving the roundabout."),
        .init(text: "If you miss your exit in a roundabout, you should:", answers: ["Stop and back up", "Continue around and take the next exit", "Make a U-turn", "Honk your horn"], correctAnswer: 1, explanation: "If you miss your exit, continue around the roundabout and take the next available exit. Never stop or back up in a roundabout."),
        .init(text: "Large vehicles in roundabouts may need to:", answers: ["Drive in the center", "Use both lanes", "Stop to make turns", "Drive faster"], correctAnswer: 1, explanation: "Large vehicles may need to use both lanes to navigate a roundabout safely. Give them extra space and be patient.")
    ])
    
    static let roundaboutM2Quiz = Quiz(title: "Roundabouts M2", questions: [
        .init(text: "When entering a multi-lane roundabout, you should:", answers: ["Choose your lane based on your exit", "Always use the right lane", "Always use the left lane", "Use whichever lane is open"], correctAnswer: 0, explanation: "Choose your lane based on which exit you plan to take. Right lane for right exits, left lane for left exits."),
        .init(text: "What should you do if you're unsure about which exit to take?", answers: ["Stop in the roundabout", "Take the first exit", "Continue around until you're sure", "Honk your horn"], correctAnswer: 2, explanation: "If you're unsure, continue around the roundabout until you're certain about which exit to take."),
        .init(text: "Pedestrians at roundabouts should:", answers: ["Cross anywhere", "Use designated crosswalks", "Run across quickly", "Ignore traffic"], correctAnswer: 1, explanation: "Pedestrians should use designated crosswalks at roundabouts and wait for a safe gap in traffic."),
    ])
    
    static let roundaboutM3Quiz = Quiz(title: "Roundabouts M3", questions: [
        .init(text: "What is the speed limit in most roundabouts?", answers: ["15-25 mph", "35-45 mph", "55-65 mph", "There is no limit"], correctAnswer: 0, explanation: "Most roundabouts have speed limits of 15-25 mph to ensure safe navigation through the intersection."),
        .init(text: "Emergency vehicles in roundabouts have:", answers: ["No special privileges", "The right of way", "To follow all rules", "To use sirens only"], correctAnswer: 1, explanation: "Emergency vehicles with lights and sirens have the right of way in roundabouts, just as they do at other intersections."),
        .init(text: "What should you do if you see a cyclist in a roundabout?", answers: ["Honk at them", "Pass them quickly", "Give them space and be patient", "Ignore them"], correctAnswer: 2, explanation: "Give cyclists space and be patient. They have the same rights as motor vehicles in roundabouts."),
    ])

    static let maintenanceM1Quiz = Quiz(title: "Maintenance M1", questions: [
        .init(text: "How often should you check your tire pressure?", answers: ["Once a year", "Once a month", "Only when you get a flat", "Every time you drive"], correctAnswer: 1, explanation: "Check your tire pressure at least once a month and before long trips. Proper tire pressure improves safety, fuel economy, and tire life."),
        .init(text: "What is the proper way to check your engine oil?", answers: ["Check it when the engine is hot", "Check it when the engine is cold", "Check it when the engine is warm and off", "Check it while the engine is running"], correctAnswer: 2, explanation: "Check your oil when the engine is warm but turned off. Park on level ground and wait a few minutes for the oil to settle."),
        .init(text: "Your brake fluid should be:", answers: ["Clear or light yellow", "Dark brown or black", "Red or pink", "Green or blue"], correctAnswer: 0, explanation: "Brake fluid should be clear or light yellow. Dark or dirty brake fluid may indicate contamination and should be checked by a professional."),
        .init(text: "How often should you replace your windshield wipers?", answers: ["Every 6-12 months", "Only when they break", "Every 2-3 years", "Never"], correctAnswer: 0, explanation: "Replace windshield wipers every 6-12 months or when they show signs of wear. Worn wipers can reduce visibility in bad weather."),
        .init(text: "What should you do if your check engine light comes on?", answers: ["Ignore it if the car is running fine", "Have it checked by a professional", "Turn off the engine immediately", "Add more oil"], correctAnswer: 1, explanation: "If the check engine light comes on, have your vehicle checked by a qualified mechanic as soon as possible. It could indicate a serious problem.")
    ])

    static let maintenanceM2Quiz = Quiz(title: "Maintenance M2", questions: [
        .init(text: "How often should you change your engine oil?", answers: ["Every 3,000 miles", "Every 5,000-7,500 miles", "Every 10,000 miles", "Only when the light comes on"], correctAnswer: 1, explanation: "Most modern vehicles need oil changes every 5,000-7,500 miles, but check your owner's manual for specific recommendations."),
        .init(text: "What should you check before a long trip?", answers: ["Only the gas level", "Tires, fluids, lights, and brakes", "Only the oil", "Nothing special"], correctAnswer: 1, explanation: "Before a long trip, check your tires, all fluids, lights, brakes, and other essential systems."),
        .init(text: "When should you replace your air filter?", answers: ["Every 6 months", "Every 12,000-15,000 miles", "Only when it's dirty", "Never"], correctAnswer: 1, explanation: "Replace your air filter every 12,000-15,000 miles or as recommended in your owner's manual."),
    ])

    static let maintenanceM3Quiz = Quiz(title: "Maintenance M3", questions: [
        .init(text: "What is the most important maintenance item for safety?", answers: ["Oil changes", "Tire condition and pressure", "Radio tuning", "Paint condition"], correctAnswer: 1, explanation: "Tire condition and pressure are the most critical for safety. Worn or underinflated tires can cause accidents."),
        .init(text: "How can you tell if your brakes need attention?", answers: ["They squeak", "The pedal feels soft", "The car pulls to one side", "All of the above"], correctAnswer: 3, explanation: "All these signs indicate brake problems. Have your brakes checked immediately if you notice any of these issues."),
        .init(text: "What should you do if your temperature gauge shows hot?", answers: ["Continue driving", "Pull over and turn off the engine", "Add water immediately", "Turn on the heater"], correctAnswer: 1, explanation: "If your engine is overheating, pull over and turn off the engine immediately to prevent serious damage."),
    ])

    static let advancedTurnsM2Quiz = Quiz(title: "Advanced Turns M2", questions: [
        .init(text: "When making a U-turn, you should:", answers: ["Do it quickly", "Check for traffic in all directions", "Only do it on highways", "Never do it"], correctAnswer: 1, explanation: "Before making a U-turn, check for traffic in all directions and make sure it's legal and safe to do so."),
        .init(text: "What is the safest way to make a U-turn?", answers: ["In the middle of the road", "In a designated U-turn lane", "On a curve", "On a hill"], correctAnswer: 1, explanation: "Use a designated U-turn lane when available. These are designed for safe U-turns."),
        .init(text: "When should you NOT make a U-turn?", answers: ["When there's a sign prohibiting it", "When visibility is limited", "When traffic is heavy", "All of the above"], correctAnswer: 3, explanation: "Don't make U-turns when prohibited by signs, when visibility is limited, or when traffic is heavy."),
    ])

    static let advancedTurnsM3Quiz = Quiz(title: "Advanced Turns M3", questions: [
        .init(text: "What should you do if you're unsure about making a turn?", answers: ["Go ahead anyway", "Find an alternative route", "Ask a passenger", "Speed up"], correctAnswer: 1, explanation: "If you're unsure about making a turn, find an alternative route. It's better to be safe than sorry."),
        .init(text: "When turning around in a residential area, you should:", answers: ["Use any driveway", "Be extra careful of children", "Honk your horn", "Speed up"], correctAnswer: 1, explanation: "In residential areas, be extra careful of children who may be playing and could dart into the street."),
        .init(text: "What is the most important thing when making any turn?", answers: ["Speed", "Visibility", "Horn usage", "Radio volume"], correctAnswer: 1, explanation: "Visibility is the most important factor. Make sure you can see clearly in all directions before making any turn."),
    ])

    static let distractionM2Quiz = Quiz(title: "Distractions M2", questions: [
        .init(text: "What should you do with your phone while driving?", answers: ["Use it hands-free", "Put it in the glove compartment", "Hold it in your hand", "Use it only at stop lights"], correctAnswer: 1, explanation: "Put your phone in the glove compartment or another location where you can't reach it while driving."),
        .init(text: "How can you safely use GPS while driving?", answers: ["Program it while driving", "Program it before you start", "Have a passenger program it", "Both B and C"], correctAnswer: 3, explanation: "Program your GPS before you start driving or have a passenger program it for you."),
        .init(text: "What should you do if you need to eat while driving?", answers: ["Eat while driving", "Pull over to eat", "Eat only at stop lights", "Skip eating"], correctAnswer: 1, explanation: "If you need to eat, pull over to a safe location. Eating while driving is a distraction."),
    ])

    static let distractionM3Quiz = Quiz(title: "Distractions M3", questions: [
        .init(text: "What is the best way to stay focused while driving?", answers: ["Listen to loud music", "Talk on the phone", "Focus on the road ahead", "Think about other things"], correctAnswer: 2, explanation: "Focus on the road ahead and your driving task. Keep your mind engaged with driving."),
        .init(text: "How often should you take breaks on long trips?", answers: ["Every hour", "Every 2 hours", "Every 4 hours", "Never"], correctAnswer: 1, explanation: "Take breaks every 2 hours or 100 miles to stay alert and avoid fatigue."),
        .init(text: "What should you do if you become distracted while driving?", answers: ["Continue driving", "Pull over and refocus", "Speed up to get there faster", "Turn up the radio"], correctAnswer: 1, explanation: "If you become distracted, pull over to a safe location and refocus before continuing."),
    ])

    static let ruralM1Quiz = Quiz(title: "Rural Roads M1", questions: [
        .init(text: "When driving on rural roads, you should:", answers: ["Slow down and be extra cautious", "Speed up to get to your destination faster", "Ignore road signs", "Drive with your high beams on"], correctAnswer: 1, explanation: "Rural roads often have limited visibility and unexpected hazards. Slow down and be extra cautious."),
        .init(text: "What should you do if you encounter a deer on the road?", answers: ["Swerve to avoid it", "Brake hard", "Try to steer around it", "Speed up"], correctAnswer: 1, explanation: "If you see a deer on the road, swerve to avoid it. Braking suddenly can cause you to lose control."),
        .init(text: "On rural roads, you should:", answers: ["Use your high beams", "Turn off your headlights", "Use low beams", "Use fog lights"], correctAnswer: 1, explanation: "Rural roads often have limited visibility. Use your high beams to increase your visibility and be extra cautious."),
    ])

    static let ruralM2Quiz = Quiz(title: "Rural Roads M2", questions: [
        .init(text: "When driving on gravel roads, you should:", answers: ["Speed up to avoid getting stuck", "Slow down and be extra cautious", "Drive in the center", "Use your high beams always"], correctAnswer: 1, explanation: "Gravel roads can be unpredictable. Slow down and be extra cautious, especially after rain when the surface may be slippery."),
        .init(text: "What should you do if you encounter a tractor on a rural road?", answers: ["Honk your horn", "Pass immediately", "Be patient and wait for a safe passing zone", "Drive very close behind"], correctAnswer: 2, explanation: "Be patient and wait for a safe passing zone. Don't pass on curves, hills, or other areas with limited visibility."),
        .init(text: "On unpaved roads, you should:", answers: ["Drive faster to avoid getting stuck", "Slow down and be extra cautious", "Drive in the center of the road", "Use your high beams always"], correctAnswer: 1, explanation: "Unpaved roads can be unpredictable. Slow down and be extra cautious, especially after rain when the surface may be slippery."),
    ])

    static let ruralM3Quiz = Quiz(title: "Rural Roads M3", questions: [
        .init(text: "What should you do if you encounter a slow-moving vehicle on a rural road?", answers: ["Honk your horn continuously", "Pass immediately when you see a gap", "Be patient and wait for a safe passing zone", "Drive very close behind them"], correctAnswer: 2, explanation: "Be patient and wait for a safe passing zone. Don't pass on curves, hills, or other areas with limited visibility."),
        .init(text: "Rural roads often have:", answers: ["More traffic lights", "Higher speed limits", "Narrower lanes and sharp curves", "More lanes"], correctAnswer: 2, explanation: "Rural roads often have narrower lanes, sharp curves, and limited visibility. Adjust your speed and driving accordingly."),
        .init(text: "What should you do if you break down on a rural road?", answers: ["Walk to the nearest town", "Stay with your vehicle", "Try to fix it yourself", "Leave the car and hitchhike"], correctAnswer: 1, explanation: "Stay with your vehicle and call for help. Walking on rural roads can be dangerous, especially at night."),
    ])

    static let roadTripM2Quiz = Quiz(title: "Road Trips M2", questions: [
        .init(text: "How often should you take breaks on a long road trip?", answers: ["Every 2 hours or 100 miles", "Only when you're tired", "Every 4 hours", "Never"], correctAnswer: 0, explanation: "Take breaks every 2 hours or 100 miles to stay alert and avoid fatigue. Get out of the car, stretch, and refresh yourself."),
        .init(text: "What should you pack for a road trip emergency?", answers: ["Only a spare tire", "First aid kit, flashlight, jumper cables, and emergency supplies", "Only a map", "Nothing special"], correctAnswer: 1, explanation: "Pack a first aid kit, flashlight, jumper cables, emergency supplies, and other essentials for unexpected situations."),
        .init(text: "When planning a route for a road trip, you should:", answers: ["Always take the shortest route", "Consider traffic, weather, and road conditions", "Only use highways", "Avoid all toll roads"], correctAnswer: 1, explanation: "Consider traffic patterns, weather conditions, road construction, and alternative routes when planning your trip."),
    ])

    static let roadTripM3Quiz = Quiz(title: "Road Trips M3", questions: [
        .init(text: "If you become drowsy while driving on a road trip, you should:", answers: ["Turn up the radio", "Open the window", "Pull over and rest", "Drink coffee"], correctAnswer: 2, explanation: "If you become drowsy, pull over to a safe location and rest. Don't try to fight fatigue while driving - it's extremely dangerous."),
        .init(text: "What should you do if you get lost on a road trip?", answers: ["Keep driving until you find your way", "Pull over and check your map or GPS", "Ask the first person you see", "Turn around immediately"], correctAnswer: 1, explanation: "Pull over to a safe location and check your map or GPS. Don't try to navigate while driving."),
        .init(text: "How should you handle rest stops on a road trip?", answers: ["Skip them to save time", "Use them for breaks and stretching", "Only use them for gas", "Avoid them completely"], correctAnswer: 1, explanation: "Use rest stops for breaks, stretching, and to stay alert. Regular breaks are essential for safe long-distance driving."),
    ])

    static let postAccidentM1Quiz = Quiz(title: "Post-Accident M1", questions: [
        .init(text: "What should you do immediately after an accident?", answers: ["Call 911", "Exchange information with the other driver", "Move your vehicle to a safe location", "Stay at the scene"], correctAnswer: 1, explanation: "Always call 911 immediately after an accident. Exchange information with the other driver to ensure both parties are aware of the situation."),
        .init(text: "What should you do if someone is injured?", answers: ["Stay at the scene and wait for help", "Move the injured person to a safe location", "Call 911 and stay at the scene", "Leave the scene immediately"], correctAnswer: 2, explanation: "If someone is injured, move them to a safe location and call 911 immediately. Stay at the scene to provide assistance if possible."),
        .init(text: "What should you do if your vehicle is drivable?", answers: ["Try to drive it to a safe location", "Leave it where it is", "Call a tow truck", "Try to fix it yourself"], correctAnswer: 1, explanation: "If your vehicle is drivable, try to drive it to a safe location. If not, call a tow truck or try to fix it yourself."),
    ])

    static let postAccidentM2Quiz = Quiz(title: "Post-Accident M2", questions: [
        .init(text: "What information should you exchange with the other driver?", answers: ["Only your name", "Name, address, phone number, insurance info, and license plate", "Only your insurance information", "Nothing"], correctAnswer: 1, explanation: "Exchange name, address, phone number, insurance information, and license plate numbers with the other driver."),
        .init(text: "If you're involved in a hit-and-run accident, you should:", answers: ["Chase the other driver", "Call the police immediately", "Wait for them to return", "Forget about it"], correctAnswer: 1, explanation: "If the other driver leaves the scene, call the police immediately. Try to remember as many details about the vehicle as possible."),
        .init(text: "When should you call the police after an accident?", answers: ["Only if someone is injured", "Only if there's significant damage", "Always, regardless of damage", "Never"], correctAnswer: 2, explanation: "Call the police if there are injuries, significant damage, or if the other driver is uncooperative. It's better to have a police report."),
    ])

    static let postAccidentM3Quiz = Quiz(title: "Post-Accident M3", questions: [
        .init(text: "What should you NOT do after an accident?", answers: ["Admit fault", "Take photos of the damage", "Get contact information from witnesses", "Move to a safe location"], correctAnswer: 0, explanation: "Never admit fault at the scene of an accident. Let the insurance companies and authorities determine who was at fault based on the evidence."),
        .init(text: "What should you do if you're injured in an accident?", answers: ["Wait for the police", "Seek medical attention immediately", "Drive yourself to the hospital", "Ignore the injury"], correctAnswer: 1, explanation: "If you're injured, seek medical attention immediately. Even minor injuries can become serious if not treated."),
        .init(text: "How long should you keep accident documentation?", answers: ["A few days", "A few weeks", "At least a year", "Forever"], correctAnswer: 2, explanation: "Keep all accident documentation for at least a year, as insurance claims and legal issues can take time to resolve."),
    ])

    static let ecoDrivingM1Quiz = Quiz(title: "Eco-Driving M1", questions: [
        .init(text: "What is the most fuel-efficient way to accelerate?", answers: ["Quickly", "Gradually", "In bursts", "It doesn't matter"], correctAnswer: 1, explanation: "Accelerate gradually to improve fuel economy. Rapid acceleration uses more fuel and is less efficient."),
        .init(text: "How can you reduce aerodynamic drag while driving?", answers: ["Remove your roof rack when not in use", "Drive with windows down always", "Add large accessories to your car", "Drive faster"], correctAnswer: 0, explanation: "Remove roof racks, bike racks, and other accessories when not in use to reduce aerodynamic drag and improve fuel economy."),
        .init(text: "What is the most fuel-efficient way to drive on hills?", answers: ["Speed up going uphill", "Maintain steady speed", "Coast downhill", "Both B and C"], correctAnswer: 3, explanation: "Maintain a steady speed going uphill and coast downhill when safe to do so. This is the most fuel-efficient approach."),
    ])

    static let ecoDrivingM2Quiz = Quiz(title: "Eco-Driving M2", questions: [
        .init(text: "What should you do to improve fuel economy when approaching a red light?", answers: ["Speed up to get there faster", "Coast to a stop", "Brake hard at the last moment", "Change lanes"], correctAnswer: 1, explanation: "Coast to a stop when approaching a red light instead of accelerating and then braking hard. This saves fuel and reduces wear on your brakes."),
        .init(text: "How can you reduce aerodynamic drag while driving?", answers: ["Remove your roof rack when not in use", "Drive with windows down always", "Add large accessories to your car", "Drive faster"], correctAnswer: 0, explanation: "Remove roof racks, bike racks, and other accessories when not in use to reduce aerodynamic drag and improve fuel economy."),
        .init(text: "What is the most fuel-efficient way to accelerate?", answers: ["Quickly", "Gradually", "In bursts", "It doesn't matter"], correctAnswer: 1, explanation: "Accelerate gradually to improve fuel economy. Rapid acceleration uses more fuel and is less efficient."),
    ])

    static let ecoDrivingM3Quiz = Quiz(title: "Eco-Driving M3", questions: [
        .init(text: "What should you do with your car's weight to improve fuel economy?", answers: ["Add more weight", "Remove unnecessary items", "Keep it the same", "It doesn't matter"], correctAnswer: 1, explanation: "Remove unnecessary items from your car to reduce weight and improve fuel economy."),
        .init(text: "How can you improve fuel economy in cold weather?", answers: ["Warm up your car for 10 minutes", "Drive immediately", "Use the heater less", "Drive faster"], correctAnswer: 1, explanation: "Drive immediately after starting your car. Modern engines don't need long warm-up periods, and idling wastes fuel."),
        .init(text: "What is the most fuel-efficient way to drive on hills?", answers: ["Speed up going uphill", "Maintain steady speed", "Coast downhill", "Both B and C"], correctAnswer: 3, explanation: "Maintain a steady speed going uphill and coast downhill when safe to do so. This is the most fuel-efficient approach."),
    ])

    static let trafficLawsM1Quiz = Quiz(title: "Traffic Laws M1", questions: [
        .init(text: "What is the speed limit in a school zone when children are present?", answers: ["The same as the regular speed limit", "Usually 15-25 mph", "The same as the highway", "There is no special limit"], correctAnswer: 1, explanation: "School zones typically have reduced speed limits of 15-25 mph when children are present, usually during school hours."),
        .init(text: "What should you do when you see a flashing yellow light?", answers: ["Stop completely", "Slow down and proceed with caution", "Speed up to get through", "Ignore it"], correctAnswer: 1, explanation: "A flashing yellow light means slow down and proceed with caution. It's a warning, not a stop signal."),
        .init(text: "What does a solid red light mean?", answers: ["Stop and wait", "Stop and proceed if clear", "Slow down", "Speed up"], correctAnswer: 0, explanation: "A solid red light means stop and wait until it turns green. You may turn right on red after stopping and yielding, unless prohibited."),
    ])

    static let trafficLawsM2Quiz = Quiz(title: "Traffic Laws M2", questions: [
        .init(text: "What is the speed limit in a school zone when children are present?", answers: ["The same as the regular speed limit", "Usually 15-25 mph", "The same as the highway", "There is no special limit"], correctAnswer: 1, explanation: "School zones typically have reduced speed limits of 15-25 mph when children are present, usually during school hours."),
        .init(text: "What should you do when you see a flashing yellow light?", answers: ["Stop completely", "Slow down and proceed with caution", "Speed up to get through", "Ignore it"], correctAnswer: 1, explanation: "A flashing yellow light means slow down and proceed with caution. It's a warning, not a stop signal."),
        .init(text: "What does a solid red light mean?", answers: ["Stop and wait", "Stop and proceed if clear", "Slow down", "Speed up"], correctAnswer: 0, explanation: "A solid red light means stop and wait until it turns green. You may turn right on red after stopping and yielding, unless prohibited."),
    ])

    static let trafficLawsM3Quiz = Quiz(title: "Traffic Laws M3", questions: [
        .init(text: "What should you do if you're pulled over by police?", answers: ["Drive away quickly", "Pull over safely and stay in your car", "Get out of your car immediately", "Ignore the officer"], correctAnswer: 1, explanation: "Pull over safely to the right side of the road and stay in your car with your hands visible on the steering wheel."),
        .init(text: "What is the penalty for driving without a license?", answers: ["A warning", "A fine and possible jail time", "Nothing", "A small fine"], correctAnswer: 1, explanation: "Driving without a license can result in fines and possible jail time, depending on the circumstances."),
        .init(text: "What should you do if you see an emergency vehicle with lights and sirens?", answers: ["Speed up to get out of the way", "Pull over to the right and stop", "Continue driving normally", "Honk your horn"], correctAnswer: 1, explanation: "Pull over to the right side of the road and stop to allow emergency vehicles to pass safely."),
    ])

    static let reverseParkingM1Quiz = Quiz(title: "Reverse Parking M1", questions: [
        .init(text: "What is the advantage of backing into a parking space?", answers: ["It's faster", "It's easier to exit later", "It saves gas", "It looks cooler"], correctAnswer: 1, explanation: "Backing into a space makes it easier and safer to exit later, as you have better visibility when pulling out forward."),
        .init(text: "When backing, you should steer the wheel:", answers: ["In the direction you want the back of the car to go", "Opposite to the direction you want to go", "Straight ahead", "It doesn't matter"], correctAnswer: 0, explanation: "When backing, steer the wheel in the direction you want the back of the car to go. This is the opposite of forward steering."),
        .init(text: "What should you do before backing into a space?", answers: ["Honk your horn", "Check for pedestrians and obstacles", "Turn on your hazard lights", "Speed up"], correctAnswer: 1, explanation: "Before backing, check for pedestrians, children, and obstacles in your path. Take your time and be thorough."),
    ])

    static let reverseParkingM2Quiz = Quiz(title: "Reverse Parking M2", questions: [
        .init(text: "What is the advantage of backing into a parking space?", answers: ["It's faster", "It's easier to exit later", "It saves gas", "It looks cooler"], correctAnswer: 1, explanation: "Backing into a space makes it easier and safer to exit later, as you have better visibility when pulling out forward."),
        .init(text: "When backing, you should steer the wheel:", answers: ["In the direction you want the back of the car to go", "Opposite to the direction you want to go", "Straight ahead", "It doesn't matter"], correctAnswer: 0, explanation: "When backing, steer the wheel in the direction you want the back of the car to go. This is the opposite of forward steering."),
        .init(text: "What should you do before backing into a space?", answers: ["Honk your horn", "Check for pedestrians and obstacles", "Turn on your hazard lights", "Speed up"], correctAnswer: 1, explanation: "Before backing, check for pedestrians, children, and obstacles in your path. Take your time and be thorough."),
    ])

    static let reverseParkingM3Quiz = Quiz(title: "Reverse Parking M3", questions: [
        .init(text: "If you're unsure about backing into a space, you should:", answers: ["Try anyway", "Find a different parking spot", "Ask someone to guide you", "Both B and C"], correctAnswer: 3, explanation: "If you're unsure about backing into a space, either find a different spot or ask someone to guide you. Don't take unnecessary risks."),
        .init(text: "What should you do if you hit something while backing?", answers: ["Keep backing", "Stop immediately and check for damage", "Speed up to get out", "Ignore it"], correctAnswer: 1, explanation: "Stop immediately and check for damage. Don't continue backing if you've hit something."),
        .init(text: "When backing out of a parking space, you should:", answers: ["Only use your rearview mirror", "Look primarily over your right shoulder", "Turn your head and look back, while also checking mirrors", "Let your camera do all the work"], correctAnswer: 2, explanation: "You must physically look back while also checking all mirrors and your backup camera to ensure the path is completely clear."),
    ])

    static let interstateM1Quiz = Quiz(title: "Interstate M1", questions: [
        .init(text: "What is the minimum speed limit on most interstates?", answers: ["35 mph", "45 mph", "55 mph", "65 mph"], correctAnswer: 1, explanation: "Most interstates have a minimum speed limit of 45 mph. Driving too slowly can be as dangerous as driving too fast."),
        .init(text: "When driving on an interstate, you should stay in the right lane unless:", answers: ["You want to drive faster", "You're passing another vehicle", "The right lane is crowded", "You're in a hurry"], correctAnswer: 1, explanation: "Stay in the right lane unless you're passing another vehicle. The left lane is for passing, not for faster driving."),
        .init(text: "What should you do if you miss your interstate exit?", answers: ["Stop and back up", "Make a U-turn", "Continue to the next exit", "Pull over and wait"], correctAnswer: 2, explanation: "If you miss your exit, continue to the next exit. Never stop, back up, or make a U-turn on an interstate highway."),
    ])

    static let interstateM2Quiz = Quiz(title: "Interstate M2", questions: [
        .init(text: "What is the minimum speed limit on most interstates?", answers: ["35 mph", "45 mph", "55 mph", "65 mph"], correctAnswer: 1, explanation: "Most interstates have a minimum speed limit of 45 mph. Driving too slowly can be as dangerous as driving too fast."),
        .init(text: "When driving on an interstate, you should stay in the right lane unless:", answers: ["You want to drive faster", "You're passing another vehicle", "The right lane is crowded", "You're in a hurry"], correctAnswer: 1, explanation: "Stay in the right lane unless you're passing another vehicle. The left lane is for passing, not for faster driving."),
        .init(text: "What should you do if you miss your interstate exit?", answers: ["Stop and back up", "Make a U-turn", "Continue to the next exit", "Pull over and wait"], correctAnswer: 2, explanation: "If you miss your exit, continue to the next exit. Never stop, back up, or make a U-turn on an interstate highway."),
    ])

    static let interstateM3Quiz = Quiz(title: "Interstate M3", questions: [
        .init(text: "How far ahead should you scan when driving on an interstate?", answers: ["1-2 seconds", "5-7 seconds", "12-15 seconds", "20-30 seconds"], correctAnswer: 2, explanation: "On interstates, scan 12-15 seconds ahead (about 1/4 mile at highway speeds) to identify potential hazards early."),
        .init(text: "What should you do if you break down on an interstate?", answers: ["Stay in your car", "Get out and walk", "Move to the shoulder and call for help", "Try to fix it yourself"], correctAnswer: 2, explanation: "Move to the shoulder, turn on your hazard lights, and call for help. Stay in your car unless it's unsafe."),
        .init(text: "When should you use rest areas on interstates?", answers: ["Only for gas", "For breaks, stretching, and rest", "Never", "Only at night"], correctAnswer: 1, explanation: "Use rest areas for breaks, stretching, and rest to stay alert and avoid fatigue on long trips."),
    ])

    static let threePointTurnM1Quiz = Quiz(title: "3-Point Turns M1", questions: [
        .init(text: "When should you NOT attempt a three-point turn?", answers: ["On a curve", "On a hill", "On a narrow road", "All of the above"], correctAnswer: 3, explanation: "Avoid three-point turns on curves, hills, or narrow roads where visibility is limited or there isn't enough space."),
        .init(text: "The first movement in a three-point turn is:", answers: ["Backing up", "Turning left", "Turning right", "Going straight"], correctAnswer: 1, explanation: "The first movement is turning the steering wheel left and moving forward until you're at an angle to the road."),
        .init(text: "During a three-point turn, you should:", answers: ["Rush to complete it quickly", "Take your time and be thorough", "Ignore other traffic", "Use only your mirrors"], correctAnswer: 1, explanation: "Take your time during a three-point turn. Check for traffic in all directions and make sure you have enough space."),
    ])

    static let threePointTurnM2Quiz = Quiz(title: "3-Point Turns M2", questions: [
        .init(text: "When should you NOT attempt a three-point turn?", answers: ["On a curve", "On a hill", "On a narrow road", "All of the above"], correctAnswer: 3, explanation: "Avoid three-point turns on curves, hills, or narrow roads where visibility is limited or there isn't enough space."),
        .init(text: "The first movement in a three-point turn is:", answers: ["Backing up", "Turning left", "Turning right", "Going straight"], correctAnswer: 1, explanation: "The first movement is turning the steering wheel left and moving forward until you're at an angle to the road."),
        .init(text: "During a three-point turn, you should:", answers: ["Rush to complete it quickly", "Take your time and be thorough", "Ignore other traffic", "Use only your mirrors"], correctAnswer: 1, explanation: "Take your time during a three-point turn. Check for traffic in all directions and make sure you have enough space."),
    ])

    static let threePointTurnM3Quiz = Quiz(title: "3-Point Turns M3", questions: [
        .init(text: "What should you do before starting a three-point turn?", answers: ["Honk your horn", "Signal your intention", "Turn on your hazard lights", "Speed up"], correctAnswer: 1, explanation: "Signal your intention to turn before starting the maneuver. This alerts other drivers to your actions."),
        .init(text: "A three-point turn should be completed in:", answers: ["Exactly 3 movements", "As many movements as needed", "2 movements maximum", "1 movement"], correctAnswer: 1, explanation: "While it's called a three-point turn, you should use as many movements as needed to complete the turn safely. Don't rush the process."),
        .init(text: "What should you do if you can't complete a three-point turn safely?", answers: ["Keep trying", "Find an alternative route", "Ask for help", "Speed up"], correctAnswer: 1, explanation: "If you can't complete a three-point turn safely, find an alternative route. Don't take unnecessary risks."),
    ])

    static let roadSignsM1Quiz = Quiz(title: "Road Signs M1", questions: [
        .init(text: "What do the colors on road signs mean?", answers: ["They're just for decoration", "They indicate the type of road", "They tell you what you must or must not do", "They're used for decorative purposes"], correctAnswer: 2, explanation: "Colors on road signs are used to convey information about the road ahead. They tell you what you must or must not do."),
        .init(text: "What is the most important thing to remember when driving?", answers: ["Speed", "Patience and awareness", "Getting to your destination quickly", "Following other drivers"], correctAnswer: 2, explanation: "Patience and awareness are crucial in city driving. There are many potential hazards and you need to be alert and patient with other drivers and pedestrians."),
        .init(text: "What should you do if you see a stop sign?", answers: ["Stop completely", "Slow down and proceed with caution", "Speed up to get through", "Ignore it"], correctAnswer: 1, explanation: "A stop sign means stop completely and proceed with caution. It's a mandatory stop sign."),
    ])

    static let roadSignsM2Quiz = Quiz(title: "Road Signs M2", questions: [
        .init(text: "What color are regulatory signs?", answers: ["Red and white", "Yellow and black", "Green and white", "Blue and white"], correctAnswer: 0, explanation: "Regulatory signs are typically red and white. They tell you what you must or must not do, such as stop, yield, or speed limit signs."),
        .init(text: "What color are warning signs?", answers: ["Red and white", "Yellow and black", "Green and white", "Blue and white"], correctAnswer: 1, explanation: "Warning signs are typically yellow and black. They warn you about upcoming hazards or changes in the road."),
        .init(text: "What shape are stop signs?", answers: ["Circle", "Triangle", "Octagon", "Rectangle"], correctAnswer: 2, explanation: "Stop signs are octagonal (8-sided) and red with white letters. This unique shape makes them easily recognizable."),
    ])

    static let roadSignsM3Quiz = Quiz(title: "Road Signs M3", questions: [
        .init(text: "What does a diamond-shaped sign indicate?", answers: ["A regulatory requirement", "A warning", "A guide to services", "A construction zone"], correctAnswer: 1, explanation: "Diamond-shaped signs are warning signs that alert you to potential hazards or changes in the road ahead."),
        .init(text: "What color are guide signs?", answers: ["Red and white", "Yellow and black", "Green and white", "Orange and black"], correctAnswer: 2, explanation: "Guide signs are typically green and white. They provide information about destinations, routes, and services."),
        .init(text: "What do orange signs typically indicate?", answers: ["Construction zones", "School zones", "Speed limits", "Rest areas"], correctAnswer: 0, explanation: "Orange signs typically indicate construction zones and work areas. Slow down and be prepared for workers and equipment."),
    ])

    static let advancedTurnsM1Quiz = Quiz(title: "Advanced Turns M1", questions: [
        .init(text: "What is an advanced turn?", answers: ["A turn at high speed", "A turn requiring special signaling", "A turn with multiple lanes involved", "A turn performed in a complex intersection"], correctAnswer: 3, explanation: "Advanced turns often occur at complex intersections and require extra attention to signaling and lane position."),
        .init(text: "When should you signal for an advanced turn?", answers: ["At the last second", "At least 100 feet before the turn", "Only if other cars are present", "After you start turning"], correctAnswer: 1, explanation: "Signal at least 100 feet before the turn to alert other drivers of your intentions."),
        .init(text: "What is the most important thing to check before making an advanced turn?", answers: ["Your speed", "Your mirrors and blind spots", "The radio volume", "The weather"], correctAnswer: 1, explanation: "Always check your mirrors and blind spots before making any turn, especially advanced ones.")
    ])

    static let distractionM1Quiz = Quiz(title: "Distractions M1", questions: [
        .init(text: "Which of the following is a cognitive distraction?", answers: ["Texting", "Daydreaming", "Eating", "Adjusting the radio"], correctAnswer: 1, explanation: "Cognitive distractions take your mind off driving, such as daydreaming or being lost in thought."),
        .init(text: "What should you do if you feel distracted while driving?", answers: ["Keep driving", "Pull over safely and refocus", "Speed up to finish sooner", "Call someone for help"], correctAnswer: 1, explanation: "If you feel distracted, pull over safely and refocus before continuing your drive."),
        .init(text: "Which is NOT a type of distraction?", answers: ["Visual", "Manual", "Auditory", "Cognitive"], correctAnswer: 2, explanation: "The three main types of distraction are visual, manual, and cognitive.")
    ])

    static let roadTripM1Quiz = Quiz(title: "Road Trips M1", questions: [
        .init(text: "What is the first thing you should do before a road trip?", answers: ["Pack snacks", "Check your vehicle's condition", "Plan your playlist", "Invite friends"], correctAnswer: 1, explanation: "Checking your vehicle's condition is the most important first step before a road trip."),
        .init(text: "How should you plan your route for a road trip?", answers: ["Use only GPS", "Check for road closures and weather", "Just start driving", "Ask friends for directions"], correctAnswer: 1, explanation: "Always check for road closures, weather, and alternate routes before starting your trip."),
        .init(text: "What is a good rule for rest stops on a road trip?", answers: ["Stop only when you need gas", "Take a break every 2 hours or 100 miles", "Never stop", "Stop at every exit"], correctAnswer: 1, explanation: "Taking regular breaks helps you stay alert and safe on long trips.")
    ])
}

extension Course {
    static let allCourses: [Course] = [
        Course(title: "Defensive Driving", description: "Anticipate and avoid hazards", icon: "shield.checkered", color: .green, category: .core, imageName: "shield.lefthalf.filled", modules: [
            .init(title: "Module 1: Core Principles", content: [ .init(title: "The SIPDE System", type: "Video"), .init(title: "Identifying Escape Routes", type: "Reading") ], quiz: .defensiveDrivingM1Quiz),
            .init(title: "Module 2: Advanced Techniques", content: [ .init(title: "Mastering Following Distance", type: "Video"), .init(title: "Handling Tailgaters Safely", type: "Video") ], quiz: .defensiveDrivingM2Quiz),
            .init(title: "Module 3: Hazard Recognition", content: [ .init(title: "Identifying Road Hazards", type: "Video"), .init(title: "Emergency Response Planning", type: "Reading") ], quiz: .defensiveDrivingM3Quiz)
        ]),
        Course(title: "Highway Skills", description: "Merging, lane changes, and more", icon: "road.lanes", color: .blue, category: .advanced, imageName: "road.lanes", modules: [
            .init(title: "Module 1: On-Ramps and Off-Ramps", content: [ .init(title: "Merging and Exiting at Speed", type: "Video") ], quiz: .highwaySkillsM1Quiz),
            .init(title: "Module 2: Lane Discipline", content: [ .init(title: "Blind Spot Checks", type: "Video"), .init(title: "Understanding Highway Hypnosis", type: "Reading") ], quiz: .highwaySkillsM2Quiz),
            .init(title: "Module 3: High-Speed Safety", content: [ .init(title: "Managing High Speeds", type: "Video"), .init(title: "Emergency Highway Stops", type: "Reading") ], quiz: .highwaySkillsM3Quiz)
        ]),
        Course(title: "Night Driving", description: "Master driving in low light", icon: "moon.stars.fill", color: .purple, category: .situational, imageName: "moon.stars.fill", modules: [
            .init(title: "Module 1: Seeing and Being Seen", content: [ .init(title: "Using Your Headlights Correctly", type: "Video"), .init(title: "How to Handle Glare", type: "Reading") ], quiz: .nightDrivingM1Quiz),
            .init(title: "Module 2: Night Vision Techniques", content: [ .init(title: "Improving Night Vision", type: "Video"), .init(title: "Scanning Techniques", type: "Reading") ], quiz: .nightDrivingM2Quiz),
            .init(title: "Module 3: Night Hazards", content: [ .init(title: "Wildlife and Pedestrians", type: "Video"), .init(title: "Fatigue Management", type: "Reading") ], quiz: .nightDrivingM3Quiz)
        ]),
        Course(title: "Parking Pro", description: "Parallel, angled, and lot parking", icon: "parkingsign.circle.fill", color: .orange, category: .advanced, imageName: "parkingsign.circle.fill", modules: [
            .init(title: "Module 1: Lot Parking", content: [ .init(title: "Angled vs. Straight", type: "Video")], quiz: .parkingProM1Quiz),
            .init(title: "Module 2: Parallel Parking", content: [ .init(title: "Step-by-Step Guide", type: "Video")], quiz: .parkingProM2Quiz),
            .init(title: "Module 3: Advanced Parking", content: [ .init(title: "Tight Spaces", type: "Video"), .init(title: "Parking on Hills", type: "Reading") ], quiz: .parkingProM3Quiz)
        ]),
        Course(title: "Inclement Weather", description: "Driving in rain, fog, and snow", icon: "cloud.rain.fill", color: .gray, category: .situational, imageName: "cloud.sleet.fill", modules: [
            .init(title: "Module 1: Driving in Rain", content: [ .init(title: "Hydroplaning Avoidance", type: "Video")], quiz: .weatherM1Quiz),
            .init(title: "Module 2: Snow and Ice", content: [ .init(title: "Winter Driving Techniques", type: "Video")], quiz: .weatherM2Quiz),
            .init(title: "Module 3: Extreme Weather", content: [ .init(title: "Fog and Wind", type: "Video"), .init(title: "Emergency Weather Procedures", type: "Reading") ], quiz: .weatherM3Quiz)
        ]),
        Course(title: "City Driving", description: "Navigate dense urban environments", icon: "building.2.fill", color: .pink, category: .situational, imageName: "building.columns.fill", modules: [
            .init(title: "Module 1: Urban Challenges", content: [ .init(title: "One-Way Streets and Pedestrians", type: "Video")], quiz: .cityDrivingM1Quiz),
            .init(title: "Module 2: Traffic Management", content: [ .init(title: "Heavy Traffic Navigation", type: "Video")], quiz: .cityDrivingM2Quiz),
            .init(title: "Module 3: Urban Safety", content: [ .init(title: "Construction Zones", type: "Video"), .init(title: "Night City Driving", type: "Reading") ], quiz: .cityDrivingM3Quiz)
        ]),
        Course(title: "Emergency Maneuvers", description: "Reacting to sudden events", icon: "exclamationmark.triangle.fill", color: .red, category: .advanced, imageName: "figure.walk.diamond.fill", modules: [
            .init(title: "Module 1: Evasive Actions", content: [ .init(title: "Skid Control", type: "Video")], quiz: .emergencyM1Quiz),
            .init(title: "Module 2: Vehicle Failures", content: [ .init(title: "Handling Mechanical Failures", type: "Video")], quiz: .emergencyM2Quiz),
            .init(title: "Module 3: Emergency Response", content: [ .init(title: "Accident Procedures", type: "Video"), .init(title: "First Aid Basics", type: "Reading") ], quiz: .emergencyM3Quiz)
        ]),
        Course(title: "Roundabout Navigation", description: "Mastering traffic circles with ease", icon: "arrow.triangle.swap", color: .teal, category: .advanced, imageName: "arrow.triangle.turn.up.right.circle.fill", modules: [
            .init(title: "Module 1: Roundabout Rules", content: [ .init(title: "Yielding and Lane Choice", type: "Video")], quiz: .roundaboutM1Quiz),
            .init(title: "Module 2: Multi-Lane Roundabouts", content: [ .init(title: "Lane Selection", type: "Video")], quiz: .roundaboutM2Quiz),
            .init(title: "Module 3: Complex Intersections", content: [ .init(title: "Roundabout Safety", type: "Video"), .init(title: "Emergency Vehicles", type: "Reading") ], quiz: .roundaboutM3Quiz)
        ]),
        Course(title: "Vehicle Maintenance 101", description: "Basic checks to keep your car safe", icon: "wrench.and.screwdriver.fill", color: .gray, category: .core, imageName: "gearshape.2.fill", modules: [
            .init(title: "Module 1: Fluid and Tire Checks", content: [ .init(title: "Checking Tire Pressure", type: "Video")], quiz: .maintenanceM1Quiz),
            .init(title: "Module 2: Engine Care", content: [ .init(title: "Oil and Filter Changes", type: "Video")], quiz: .maintenanceM2Quiz),
            .init(title: "Module 3: Preventive Maintenance", content: [ .init(title: "Scheduled Service", type: "Video"), .init(title: "Warning Signs", type: "Reading") ], quiz: .maintenanceM3Quiz)
        ]),
        Course(title: "Advanced Turns", description: "Perfecting U-turns and three-point turns", icon: "arrow.uturn.backward.circle", color: .indigo, category: .advanced, imageName: "arrow.uturn.backward.square.fill", modules: [
             .init(title: "Module 1: The Three-Point Turn", content: [ .init(title: "When and How to Execute", type: "Video")], quiz: .advancedTurnsM1Quiz),
             .init(title: "Module 2: U-Turns", content: [ .init(title: "Safe U-Turn Techniques", type: "Video")], quiz: .advancedTurnsM2Quiz),
             .init(title: "Module 3: Complex Maneuvers", content: [ .init(title: "Advanced Turning", type: "Video"), .init(title: "Hazard Assessment", type: "Reading") ], quiz: .advancedTurnsM3Quiz)
        ]),
        Course(title: "Distraction Avoidance", description: "Techniques to stay focused on the road", icon: "iphone.slash", color: .mint, category: .core, imageName: "phone.down.waves.left.and.right", modules: [
            .init(title: "Module 1: Identifying Distractions", content: [ .init(title: "Cognitive, Visual, and Manual", type: "Reading")], quiz: .distractionM1Quiz),
            .init(title: "Module 2: Technology Management", content: [ .init(title: "Phone and GPS Safety", type: "Video")], quiz: .distractionM2Quiz),
            .init(title: "Module 3: Focus Techniques", content: [ .init(title: "Mental Focus Strategies", type: "Video"), .init(title: "Fatigue Prevention", type: "Reading") ], quiz: .distractionM3Quiz)
        ]),
        Course(title: "Rural Road Safety", description: "Handling wildlife and unpaved roads", icon: "camera.macro", color: Color(red: 0.6, green: 0.4, blue: 0.2), category: .situational, imageName: "ladybug.fill", modules: [
            .init(title: "Module 1: Unexpected Encounters", content: [ .init(title: "Wildlife and Livestock on Roads", type: "Video")], quiz: .ruralM1Quiz),
            .init(title: "Module 2: Unpaved Roads", content: [ .init(title: "Gravel and Dirt Roads", type: "Video")], quiz: .ruralM2Quiz),
            .init(title: "Module 3: Rural Hazards", content: [ .init(title: "Slow-Moving Vehicles", type: "Video"), .init(title: "Emergency Services", type: "Reading") ], quiz: .ruralM3Quiz)
        ]),
        Course(title: "Road Trip Prep", description: "Long-distance driving strategies", icon: "map.fill", color: .cyan, category: .advanced, imageName: "map.fill", modules: [
            .init(title: "Module 1: Planning Your Trip", content: [ .init(title: "Vehicle Checks and Route Planning", type: "Reading")], quiz: .roadTripM1Quiz),
            .init(title: "Module 2: On the Road", content: [ .init(title: "Long-Distance Driving", type: "Video")], quiz: .roadTripM2Quiz),
            .init(title: "Module 3: Trip Safety", content: [ .init(title: "Fatigue Management", type: "Video"), .init(title: "Emergency Planning", type: "Reading") ], quiz: .roadTripM3Quiz)
        ]),
        Course(title: "Post-Accident Procedure", description: "What to do after a minor collision", icon: "person.text.rectangle.fill", color: .red, category: .situational, imageName: "person.text.rectangle.fill", modules: [
             .init(title: "Module 1: At the Scene", content: [ .init(title: "Staying Safe and Exchanging Info", type: "Video")], quiz: .postAccidentM1Quiz),
             .init(title: "Module 2: Documentation", content: [ .init(title: "Gathering Evidence", type: "Video")], quiz: .postAccidentM2Quiz),
             .init(title: "Module 3: Legal Process", content: [ .init(title: "Insurance Claims", type: "Video"), .init(title: "Legal Requirements", type: "Reading") ], quiz: .postAccidentM3Quiz)
        ]),
        Course(title: "Eco-Driving", description: "Save fuel and reduce emissions", icon: "leaf.arrow.circlepath", color: .green, category: .core, imageName: "fuelpump.fill", modules: [
             .init(title: "Module 1: Efficient Habits", content: [ .init(title: "Maximizing Your MPG", type: "Reading")], quiz: .ecoDrivingM1Quiz),
             .init(title: "Module 2: Vehicle Efficiency", content: [ .init(title: "Maintenance for Efficiency", type: "Video")], quiz: .ecoDrivingM2Quiz),
             .init(title: "Module 3: Advanced Techniques", content: [ .init(title: "Hybrid and Electric", type: "Video"), .init(title: "Future of Eco-Driving", type: "Reading") ], quiz: .ecoDrivingM3Quiz)
        ]),
        Course(title: "Traffic Laws & Signs", description: "Understand the rules of the road", icon: "signpost.right.fill", color: .blue, category: .core, imageName: "signpost.and.arrowtriangle.up.fill", modules: [
            .init(title: "Module 1: Common Regulations", content: [ .init(title: "Right-of-Way Rules", type: "Video")], quiz: .trafficLawsM1Quiz),
            .init(title: "Module 2: Speed Limits", content: [ .init(title: "Understanding Speed Laws", type: "Video")], quiz: .trafficLawsM2Quiz),
            .init(title: "Module 3: Enforcement", content: [ .init(title: "Traffic Stops", type: "Video"), .init(title: "Legal Consequences", type: "Reading") ], quiz: .trafficLawsM3Quiz)
        ]),
        Course(title: "Reverse Parking", description: "Backing into spaces safely", icon: "car.side.arrow.left", color: .orange, category: .advanced, imageName: "arrow.down.left.topright.rectangle.fill", modules: [
            .init(title: "Module 1: Backing-In Techniques", content: [ .init(title: "Using Mirrors and Cameras", type: "Video")], quiz: .reverseParkingM1Quiz),
            .init(title: "Module 2: Advanced Backing", content: [ .init(title: "Tight Spaces", type: "Video")], quiz: .reverseParkingM2Quiz),
            .init(title: "Module 3: Safety Considerations", content: [ .init(title: "Pedestrian Safety", type: "Video"), .init(title: "Emergency Procedures", type: "Reading") ], quiz: .reverseParkingM3Quiz)
        ]),
        Course(title: "Interstate Driving", description: "High-speed, long-distance travel", icon: "road.lanes.curved.right", color: .indigo, category: .advanced, imageName: "road.lanes", modules: [
            .init(title: "Module 1: Interstate Essentials", content: [ .init(title: "Managing High Speeds", type: "Video")], quiz: .interstateM1Quiz),
            .init(title: "Module 2: Long-Distance Travel", content: [ .init(title: "Endurance Driving", type: "Video")], quiz: .interstateM2Quiz),
            .init(title: "Module 3: Interstate Safety", content: [ .init(title: "Emergency Procedures", type: "Video"), .init(title: "Rest Stop Safety", type: "Reading") ], quiz: .interstateM3Quiz)
        ]),
        Course(title: "Three-Point Turns", description: "Turning around in tight spaces", icon: "arrow.3.trianglepath", color: .teal, category: .advanced, imageName: "arrow.3.trianglepath", modules: [
            .init(title: "Module 1: The K-Turn", content: [ .init(title: "Executing a Three-Point Turn", type: "Video")], quiz: .threePointTurnM1Quiz),
            .init(title: "Module 2: Advanced Techniques", content: [ .init(title: "Tight Space Maneuvers", type: "Video")], quiz: .threePointTurnM2Quiz),
            .init(title: "Module 3: Safety and Planning", content: [ .init(title: "Hazard Assessment", type: "Video"), .init(title: "When Not to Turn", type: "Reading") ], quiz: .threePointTurnM3Quiz)
        ]),
        Course(title: "Understanding Road Signs", description: "Regulatory, Warning, and Guide Signs", icon: "signpost.left.fill", color: .gray, category: .core, imageName: "signpost.left.fill", modules: [
            .init(title: "Module 1: The Three Types of Signs", content: [ .init(title: "What Do The Colors and Shapes Mean?", type: "Reading")], quiz: .roadSignsM1Quiz),
            .init(title: "Module 2: Regulatory Signs", content: [ .init(title: "Speed Limits and Restrictions", type: "Video")], quiz: .roadSignsM2Quiz),
            .init(title: "Module 3: Warning and Guide Signs", content: [ .init(title: "Hazard Warnings", type: "Video"), .init(title: "Navigation Signs", type: "Reading") ], quiz: .roadSignsM3Quiz)
        ])
    ]
}
