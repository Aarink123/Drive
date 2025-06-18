import Foundation
import SwiftUI

class AppData: ObservableObject {
    @Published var kids: [Kid] = []

    init() {
        // Define goals for Aarin
        let aarinGoals: [Goal] = [
            .init(title: "Smooth Acceleration", description: "Practice gradual acceleration from stops", detailedTip: "From a complete stop, imagine there is a full cup of water on your dashboard. Try to accelerate smoothly enough that it wouldn't spill. Count to 3 in your head as you press the accelerator.", whyItMatters: "Smooth acceleration improves fuel economy by up to 15% and reduces wear and tear on the engine and transmission. It also provides a more comfortable ride for passengers.", progress: 18, target: 25, color: .cyan),
            .init(title: "Speed Management", description: "Maintain speed within 5mph of limit", detailedTip: "Pay close attention to posted speed limit signs. On roads with changing limits, practice adjusting your speed before you enter the new zone.", whyItMatters: "Speeding is a leading cause of accidents. Maintaining a safe, legal speed gives you more time to react to unexpected hazards and reduces the severity of potential collisions.", progress: 35, target: 50, color: .orange),
            .init(title: "Complete Stops", description: "Perform full 3-second stops at all signs", detailedTip: "At a stop sign, come to a full stop where you feel no forward motion. Silently say 'one-thousand-one, one-thousand-two, one-thousand-three' before proceeding.", whyItMatters: "Rolling stops are illegal and dangerous. A full stop gives you time to accurately check for cross-traffic, pedestrians, and cyclists before entering an intersection.", progress: 38, target: 40, color: .red),
            .init(title: "Following Distance", description: "Maintain a 3-second gap", detailedTip: "When the car ahead of you passes a fixed object (like a sign), start counting. If you reach the object before you count to three, you're too close.", whyItMatters: "This is the single most effective way to prevent rear-end collisions. A 3-second gap provides the necessary time and distance to perceive a hazard and brake safely.", progress: 28, target: 40, color: .purple)
        ]

        // Define goals for Rishan
        let rishanGoals: [Goal] = [
            .init(title: "Advanced Lane Changes", description: "Execute lane changes on the highway with perfect mirror/head checks.", detailedTip: "Before any lane change, check your rearview mirror, side mirror, and then perform a quick head check over your shoulder to cover your blind spot. Signal for at least 3 seconds before moving.", whyItMatters: "Proper checks prevent collisions with vehicles in your blind spot, one of the most common causes of highway accidents.", progress: 15, target: 20, color: .blue),
            .init(title: "Night Driving Confidence", description: "Practice driving on unlit roads after dark.", detailedTip: "Drive on a familiar but unlit road. Practice using your high beams and dimming them for oncoming traffic. Pay attention to how your depth perception changes at night.", whyItMatters: "Night driving significantly reduces visibility. Gaining confidence helps you remain calm and make safe decisions in low-light conditions.", progress: 3, target: 5, color: .purple),
            .init(title: "Parallel Parking Mastery", description: "Successfully parallel park in 3 or fewer movements.", detailedTip: "Find a safe spot to practice between two objects (like cones). Focus on the 45-degree angle of entry and using your side mirror to judge distance from the curb.", whyItMatters: "Parallel parking is a critical urban driving skill that demonstrates excellent spatial awareness and vehicle control.", progress: 8, target: 10, color: .green),
            .init(title: "Eco-Driving Efficiency", description: "Maximize fuel efficiency by avoiding sudden acceleration.", detailedTip: "Focus on anticipating traffic flow. Coast to a stop instead of braking late. Gentle acceleration uses significantly less fuel.", whyItMatters: "Eco-driving can improve fuel economy by 10-25%, saving money and reducing your environmental impact.", progress: 22, target: 30, color: .teal)
        ]

        // Initialize kids with their data
        self.kids = [
            Kid(
                id: UUID(),
                name: "Aarin",
                age: "17",
                state: "Georgia",
                expectedTestDate: nil,
                metrics: DriveMetrics(
                    averageSpeed: 34.2,
                    distanceDrove: 15.8,
                    hardBraking: 3,
                    rapidAcceleration: 2,
                    speedingInstances: 1,
                    safetyRating: .moderate,
                    driveDuration: 35,
                    totalHoursDriven: 28.5
                ),
                recentDriveScore: 85,
                weekScore: 78,
                monthScore: 82,
                driveHistory: [
                    DriveHistory(date: "June 17, 7:30 PM", distance: 12.3, score: 85, performanceBreakdown: PerformanceBreakdown(control: 95, speed: 80, aware: 88, follow: 92, smooth: 75), maneuverAnalyses: [ManeuverAnalysis(name: "Left Turns", icon: "arrow.turn.up.left", grade: "A", description: "Smooth, good signal usage"), ManeuverAnalysis(name: "Right Turns", icon: "arrow.turn.up.right", grade: "B+", description: "Slightly wide on two turns"), ManeuverAnalysis(name: "Lane Changes", icon: "arrow.left.arrow.right", grade: "A-", description: "Good awareness, one missed blind spot check")]),
                    DriveHistory(date: "June 15, 5:00 PM", distance: 8.7, score: 92, performanceBreakdown: PerformanceBreakdown(control: 98, speed: 90, aware: 95, follow: 93, smooth: 89), maneuverAnalyses: [ManeuverAnalysis(name: "Left Turns", icon: "arrow.turn.up.left", grade: "A+", description: "Excellent control and speed"), ManeuverAnalysis(name: "Right Turns", icon: "arrow.turn.up.right", grade: "A", description: "Good signal usage"), ManeuverAnalysis(name: "Parking", icon: "p.circle", grade: "A-", description: "Well-centered in the space")]),
                    DriveHistory(date: "June 14, 8:10 AM", distance: 15.2, score: 76, performanceBreakdown: PerformanceBreakdown(control: 80, speed: 70, aware: 81, follow: 75, smooth: 72), maneuverAnalyses: [ManeuverAnalysis(name: "Following Distance", icon: "car.2", grade: "C+", description: "Followed too closely in traffic"), ManeuverAnalysis(name: "Speeding", icon: "speedometer", grade: "C", description: "Exceeded speed limit in a school zone")]),
                    DriveHistory(date: "June 12, 6:30 PM", distance: 22.0, score: 88, performanceBreakdown: PerformanceBreakdown(control: 91, speed: 85, aware: 90, follow: 89, smooth: 84), maneuverAnalyses: [ManeuverAnalysis(name: "Highway Merging", icon: "road.lanes.curved.right", grade: "B+", description: "Good speed matching, slightly late signal")]),
                    DriveHistory(date: "June 11, 4:00 PM", distance: 5.5, score: 95, performanceBreakdown: PerformanceBreakdown(control: 99, speed: 94, aware: 96, follow: 95, smooth: 97), maneuverAnalyses: [ManeuverAnalysis(name: "Stop Signs", icon: "hand.raised", grade: "A+", description: "Flawless execution of 3-second stops.")]),
                    DriveHistory(date: "June 10, 3:15 PM", distance: 10.8, score: 82, performanceBreakdown: PerformanceBreakdown(control: 85, speed: 80, aware: 84, follow: 81, smooth: 79), maneuverAnalyses: [ManeuverAnalysis(name: "Smoothness", icon: "wind", grade: "B-", description: "Some jerky braking and acceleration noted.")]),
                    DriveHistory(date: "June 8, 11:00 AM", distance: 18.1, score: 89, performanceBreakdown: PerformanceBreakdown(control: 92, speed: 88, aware: 90, follow: 91, smooth: 86), maneuverAnalyses: [ManeuverAnalysis(name: "Intersection", icon: "square.on.square", grade: "A-", description: "Good awareness at intersections.")]),
                    DriveHistory(date: "June 7, 9:00 PM", distance: 9.3, score: 81, performanceBreakdown: PerformanceBreakdown(control: 88, speed: 75, aware: 82, follow: 85, smooth: 80), maneuverAnalyses: [ManeuverAnalysis(name: "Night Driving", icon: "moon.stars", grade: "B", description: "Good headlight usage, slightly hesitant on turns.")]),
                    DriveHistory(date: "June 6, 1:00 PM", distance: 7.2, score: 93, performanceBreakdown: PerformanceBreakdown(control: 95, speed: 92, aware: 94, follow: 93, smooth: 91), maneuverAnalyses: [ManeuverAnalysis(name: "Parking", icon: "p.circle", grade: "A", description: "Confident and centered parking.")]),
                    DriveHistory(date: "June 5, 5:30 PM", distance: 14.8, score: 79, performanceBreakdown: PerformanceBreakdown(control: 83, speed: 74, aware: 80, follow: 78, smooth: 77), maneuverAnalyses: [ManeuverAnalysis(name: "Following Distance", icon: "car.2", grade: "C", description: "Consistently followed too closely behind trucks.")])
                ],
                goals: aarinGoals
            ),
            Kid(
                id: UUID(),
                name: "Rishan",
                age: "17",
                state: "Georgia",
                expectedTestDate: nil,
                metrics: DriveMetrics(
                    averageSpeed: 29.8,
                    distanceDrove: 11.2,
                    hardBraking: 0,
                    rapidAcceleration: 1,
                    speedingInstances: 0,
                    safetyRating: .safe,
                    driveDuration: 25,
                    totalHoursDriven: 41.5
                ),
                recentDriveScore: 96,
                weekScore: 94,
                monthScore: 92,
                driveHistory: [
                    DriveHistory(date: "June 17, 4:00 PM", distance: 11.2, score: 96, performanceBreakdown: PerformanceBreakdown(control: 98, speed: 95, aware: 97, follow: 96, smooth: 95), maneuverAnalyses: [ManeuverAnalysis(name: "Stop Signs", icon: "hand.raised", grade: "A+", description: "Perfect 3-second stops at every sign."), ManeuverAnalysis(name: "Awareness", icon: "eye", grade: "A", description: "Consistently scanned mirrors and blind spots.")]),
                    DriveHistory(date: "June 16, 3:00 PM", distance: 5.4, score: 95, performanceBreakdown: PerformanceBreakdown(control: 94, speed: 98, aware: 93, follow: 96, smooth: 95), maneuverAnalyses: [ManeuverAnalysis(name: "Speed Control", icon: "speedometer", grade: "A", description: "Maintained consistent speed on all roads."), ManeuverAnalysis(name: "Following Distance", icon: "car.2", grade: "A", description: "Excellent following distance at all times.")]),
                    DriveHistory(date: "June 14, 6:00 PM", distance: 11.2, score: 90, performanceBreakdown: PerformanceBreakdown(control: 92, speed: 91, aware: 88, follow: 94, smooth: 90), maneuverAnalyses: [ManeuverAnalysis(name: "Parking", icon: "p.circle", grade: "A", description: "Excellent parallel parking maneuver")]),
                    DriveHistory(date: "June 13, 1:20 PM", distance: 7.8, score: 88, performanceBreakdown: PerformanceBreakdown(control: 90, speed: 84, aware: 89, follow: 92, smooth: 85), maneuverAnalyses: [ManeuverAnalysis(name: "Lane Changes", icon: "arrow.left.arrow.right", grade: "B+", description: "All checks performed, slightly hesitant")]),
                    DriveHistory(date: "June 11, 7:00 AM", distance: 16.5, score: 94, performanceBreakdown: PerformanceBreakdown(control: 95, speed: 92, aware: 96, follow: 93, smooth: 94), maneuverAnalyses: [ManeuverAnalysis(name: "Awareness", icon: "eye", grade: "A", description: "Excellent scanning of surroundings in heavy traffic.")]),
                    DriveHistory(date: "June 10, 5:00 PM", distance: 8.1, score: 91, performanceBreakdown: PerformanceBreakdown(control: 93, speed: 90, aware: 92, follow: 91, smooth: 89), maneuverAnalyses: [ManeuverAnalysis(name: "Left Turns", icon: "arrow.turn.up.left", grade: "A-", description: "Good control, waited for safe gaps.")]),
                    DriveHistory(date: "June 9, 2:30 PM", distance: 25.3, score: 92, performanceBreakdown: PerformanceBreakdown(control: 94, speed: 90, aware: 93, follow: 91, smooth: 92), maneuverAnalyses: [ManeuverAnalysis(name: "Highway Driving", icon: "road.lanes", grade: "A-", description: "Excellent lane discipline and speed control.")]),
                    DriveHistory(date: "June 7, 6:45 PM", distance: 4.8, score: 98, performanceBreakdown: PerformanceBreakdown(control: 99, speed: 97, aware: 98, follow: 98, smooth: 99), maneuverAnalyses: [ManeuverAnalysis(name: "All-Way Stop", icon: "person.3", grade: "A+", description: "Perfectly yielded right-of-way.")]),
                    DriveHistory(date: "June 6, 8:00 PM", distance: 12.1, score: 93, performanceBreakdown: PerformanceBreakdown(control: 94, speed: 92, aware: 95, follow: 91, smooth: 93), maneuverAnalyses: [ManeuverAnalysis(name: "Night Driving", icon: "moon.stars", grade: "A-", description: "Handled glare well, confident maneuvers.")]),
                    DriveHistory(date: "June 4, 3:00 PM", distance: 10.2, score: 94, performanceBreakdown: PerformanceBreakdown(control: 95, speed: 93, aware: 95, follow: 94, smooth: 92), maneuverAnalyses: [ManeuverAnalysis(name: "Right Turns", icon: "arrow.turn.up.right", grade: "A", description: "Good turning radius and speed.")]),
                    DriveHistory(date: "June 2, 9:00 AM", distance: 19.8, score: 91, performanceBreakdown: PerformanceBreakdown(control: 93, speed: 90, aware: 92, follow: 90, smooth: 89), maneuverAnalyses: [ManeuverAnalysis(name: "Lane Keeping", icon: "arrow.up.and.down", grade: "A-", description: "Consistently centered in lane.")])
                ],
                goals: rishanGoals
            )
        ]
        
        addInitialRecommendations()
    }

    private func addInitialRecommendations() {
        guard let aarinIndex = kids.firstIndex(where: { $0.name == "Aarin" }) else { return }

        // AI Recommendations (based on Aarin's metrics like speeding and hard braking)
        let defensiveDrivingCourseID = Course.allCourses.first { $0.title == "Defensive Driving" }?.id
        let highwaySkillsCourseID = Course.allCourses.first { $0.title == "Highway Skills" }?.id
        
        var aiRecommended: [UUID] = []
        if let id = defensiveDrivingCourseID { aiRecommended.append(id) }
        if let id = highwaySkillsCourseID { aiRecommended.append(id) }
        kids[aarinIndex].aiRecommendedCourseIDs = aiRecommended

        // Parent Recommendations (a manual choice by the parent)
        let parkingProCourseID = Course.allCourses.first { $0.title == "Parking Pro" }?.id
        var parentRecommended: [UUID] = []
        if let id = parkingProCourseID { parentRecommended.append(id) }
        kids[aarinIndex].parentRecommendedCourseIDs = parentRecommended
    }
}
