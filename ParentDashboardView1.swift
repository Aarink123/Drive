import SwiftUI

// MARK: - Data Models for New Features
struct Goal: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let detailedTip: String
    let progress: Int
    let target: Int
    let color: Color
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
        .init(title: "Smooth Acceleration", description: "Practice gradual acceleration from stops", detailedTip: "From a complete stop, imagine there is a full cup of water on your dashboard. Try to accelerate smoothly enough that it wouldn't spill. Count to 3 in your head as you press the accelerator.", progress: 12, target: 20, color: .cyan),
        .init(title: "Speed Management", description: "Maintain speed within 5mph of limit", detailedTip: "Pay close attention to posted speed limit signs. On roads with changing limits, practice adjusting your speed before you enter the new zone.", progress: 20, target: 50, color: .orange),
        .init(title: "Complete Stops", description: "Perform full 3-second stops at all signs", detailedTip: "At a stop sign, come to a full stop where you feel no forward motion. Silently say 'one-thousand-one, one-thousand-two, one-thousand-three' before proceeding.", progress: 35, target: 40, color: .red),
        .init(title: "Turn Signals", description: "Use signals 100ft before every turn", detailedTip: "Make it a habit to signal before you brake. 100 feet is about half a city block. This gives other drivers ample warning of your intentions.", progress: 45, target: 50, color: .yellow),
        .init(title: "Lane Centering", description: "Stay centered in the lane", detailedTip: "Look further down the road towards the center of your lane, rather than just over the hood. This helps your brain automatically make small corrections to stay centered.", progress: 15, target: 30, color: .green),
        .init(title: "Following Distance", description: "Maintain a 3-second gap", detailedTip: "When the car ahead of you passes a fixed object (like a sign), start counting. If you reach the object before you count to three, you're too close.", progress: 22, target: 40, color: .purple),
        .init(title: "Parking Precision", description: "Center the car within parking lines", detailedTip: "As you pull into a spot, use your side mirrors to see the lines on both sides. Aim to have an equal amount of space on each side.", progress: 8, target: 15, color: .indigo),
        .init(title: "Mirror Checks", description: "Check mirrors every 5-8 seconds", detailedTip: "Develop a scanning pattern: check your rearview mirror, then your left, then the road ahead, then your right. This keeps you aware of your surroundings.", progress: 31, target: 50, color: .teal)
    ]
    
    @State private var selectedGoal: Goal?

    var body: some View {
        VStack(alignment: .leading) {
            Text("This Week's Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    Button(action: { selectedGoal = goal }) {
                       GoalCard(goal: goal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal)
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
    let goal: Goal
    @Environment(\.dismiss) var dismiss
    private let deepBlue = Color(#colorLiteral(red: 0.09019608051, green: 0.3019607961, blue: 0.5215686559, alpha: 1))

    var body: some View {
        ZStack {
            deepBlue.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                HStack {
                    Text(goal.title)
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
                
                ProgressView(value: Double(goal.progress), total: Double(goal.target))
                    .progressViewStyle(LinearProgressViewStyle(tint: goal.color))
                    .scaleEffect(y: 2)

                HStack {
                    Text("Current Progress: \(goal.progress) / \(goal.target) drives")
                    Spacer()
                }
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pro Tip:")
                        .font(.title2).fontWeight(.bold)
                        .foregroundColor(goal.color)
                    
                    Text(goal.detailedTip)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
        }
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

// MARK: - Courses Section with Quiz Functionality

struct CoursesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCourse: Course?

    // Expanded list of courses with quiz data
    let courses: [Course] = [
        Course(title: "Defensive Driving", description: "Anticipate and avoid hazards", duration: "5 Questions", icon: "shield.checkered", color: .green, quiz: .defensiveDrivingQuiz),
        Course(title: "Night Driving", description: "Master driving in low light", duration: "4 Questions", icon: "moon.stars.fill", color: .purple, quiz: .nightDrivingQuiz),
        Course(title: "Highway Skills", description: "Merging, lane changes, and more", duration: "4 Questions", icon: "road.lanes", color: .blue, quiz: .highwaySkillsQuiz),
        Course(title: "City Driving", description: "Navigate dense urban environments", duration: "1.5 hours", icon: "building.2.fill", color: .pink, quiz: nil),
        Course(title: "Parking Pro", description: "Parallel, angled, and lot parking", duration: "1 hour", icon: "parkingsign.circle.fill", color: .orange, quiz: nil),
        Course(title: "Inclement Weather", description: "Driving in rain, fog, and snow", duration: "2.5 hours", icon: "cloud.rain.fill", color: .gray, quiz: nil)
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
                                        if course.quiz != nil {
                                            selectedCourse = course
                                        }
                                    }
                            }
                        }.padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            }.foregroundColor(.white))
            .navigationBarHidden(true)
            .sheet(item: $selectedCourse) { course in
                if let quiz = course.quiz {
                    QuizView(quiz: quiz)
                }
            }
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
    let quiz: Quiz?
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
            course.quiz == nil ?
            Color.black.opacity(0.4).cornerRadius(20) : nil
        )
        .overlay(
            course.quiz == nil ?
            Text("Coming Soon").foregroundColor(.white).fontWeight(.bold) : nil
        )
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
                .foregroundColor(.green)
            
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


// MARK: - Views that were missing are now re-added

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
                        
                        // Newly Added Analysis Sections
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


// MARK: - Quiz Data
extension Quiz {
    static let defensiveDrivingQuiz = Quiz(title: "Defensive Driving", questions: [
        .init(text: "What is the '3-second rule' for?", answers: ["Parking", "Following distance", "Changing lanes", "Making a turn"], correctAnswer: 1, explanation: "The 3-second rule helps you maintain a safe following distance, giving you enough time to react to hazards."),
        .init(text: "When driving, you should be scanning the road...", answers: ["Directly in front of your car", "At your side mirrors", "10-15 seconds ahead", "At the car behind you"], correctAnswer: 2, explanation: "Scanning 10-15 seconds ahead gives you a full picture of the road and allows you to anticipate potential problems before you reach them."),
        .init(text: "An 'escape route' in defensive driving is:", answers: ["A shortcut to your destination", "The shoulder of the road", "A path to steer into to avoid a collision", "The lane with the least traffic"], correctAnswer: 2, explanation: "An escape route is an open space (like a shoulder or an empty lane) that you can move into to avoid a collision with a sudden hazard."),
        .init(text: "What does 'SIPDE' stand for?", answers: ["Stop, Indicate, Proceed, Direct, Exit", "Scan, Identify, Predict, Decide, Execute", "Speed, Inspect, Prepare, Drive, Engage", "Signal, Inspect, Pull, Depart, Enter"], correctAnswer: 1, explanation: "SIPDE is a 5-step process for defensive driving: Scan the road, Identify hazards, Predict what might happen, Decide on a course of action, and Execute that action."),
        .init(text: "You should increase your following distance when:", answers: ["Driving in sunny, clear weather", "Following a small car", "A driver behind you is tailgating", "All of the above"], correctAnswer: 2, explanation: "If a driver is tailgating you, increasing your following distance from the car in front gives you more space to brake gradually, reducing the chance of the tailgater hitting you.")
    ])
    
    static let nightDrivingQuiz = Quiz(title: "Night Driving", questions: [
        .init(text: "When should you use your high-beam headlights?", answers: ["On well-lit city streets", "In fog or heavy rain", "On unlit rural roads with no other cars", "When another car is approaching"], correctAnswer: 2, explanation: "High beams should be used on dark, unlit roads to increase visibility, but you must dim them when you see another vehicle approaching."),
        .init(text: "To reduce glare from oncoming headlights, you should look:", answers: ["Directly at the headlights", "At the center line of the road", "Towards the right edge of your lane", "At your dashboard"], correctAnswer: 2, explanation: "Looking toward the white line on the right side of the road helps you stay in your lane without being blinded by oncoming glare."),
        .init(text: "Why is driving at night more dangerous?", answers: ["Reduced visibility", "More tired drivers on the road", "Difficulty judging speed and distance", "All of the above"], correctAnswer: 3, explanation: "All these factors contribute to the increased risk of driving at night. Your vision is limited, and both you and other drivers may be more fatigued."),
        .init(text: "If an animal runs in front of your car at night, you should first:", answers: ["Swerve to avoid it", "Honk your horn loudly", "Brake firmly but safely", "Speed up to get past it"], correctAnswer: 2, explanation: "Your first reaction should be to brake safely. Swerving can cause you to lose control of your vehicle or drive into oncoming traffic, which is often more dangerous than hitting the animal.")
    ])

    static let highwaySkillsQuiz = Quiz(title: "Highway Skills", questions: [
        .init(text: "When merging onto a highway, you should:", answers: ["Stop at the end of the ramp", "Slow down and wait for a gap", "Match the speed of traffic and find a gap", "Force your way into traffic"], correctAnswer: 2, explanation: "The entrance ramp is designed for you to accelerate to the speed of highway traffic. This allows you to merge smoothly and safely into an open gap."),
        .init(text: "What is a 'blind spot'?", answers: ["An area blocked by your rearview mirror", "The area directly behind your car", "An area around your car not visible in your mirrors", "The spot you aim for when parking"], correctAnswer: 2, explanation: "Blind spots are areas to the sides of your car that cannot be seen in your mirrors. You must physically turn your head to check them before changing lanes."),
        .init(text: "When driving on a multi-lane highway, the left-most lane is generally for:", answers: ["Slower traffic and exiting", "All types of traffic", "Trucks and large vehicles", "Passing and faster-moving traffic"], correctAnswer: 3, explanation: "The left lane is typically intended for passing other vehicles. After passing, you should move back into the center or right lane to allow others to pass."),
        .init(text: "What is 'highway hypnosis'?", answers: ["A fear of driving on highways", "A trance-like state from driving long distances", "The feeling of speed when you exit a highway", "The bright glare from highway lights"], correctAnswer: 1, explanation: "Highway hypnosis is a state of reduced attention that can occur after long periods of monotonous driving. To prevent it, keep your eyes moving, take regular breaks, and stay engaged.")
    ])
}
