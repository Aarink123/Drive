import Foundation
import SwiftUI

class AppData: ObservableObject {
    @Published var kids: [Kid] = [
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
                DriveHistory(
                    date: "June 17, 7:30 PM",
                    distance: 12.3,
                    score: 85,
                    performanceBreakdown: PerformanceBreakdown(control: 95, speed: 80, aware: 88, follow: 92, smooth: 75),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Left Turns", icon: "arrow.turn.up.left", grade: "A", description: "Smooth, good signal usage"),
                        ManeuverAnalysis(name: "Right Turns", icon: "arrow.turn.up.right", grade: "B+", description: "Slightly wide on two turns"),
                        ManeuverAnalysis(name: "Lane Changes", icon: "arrow.left.arrow.right", grade: "A-", description: "Good awareness, one missed blind spot check")
                    ]
                ),
                DriveHistory(
                    date: "June 15, 5:00 PM",
                    distance: 8.7,
                    score: 92,
                    performanceBreakdown: PerformanceBreakdown(control: 98, speed: 90, aware: 95, follow: 93, smooth: 89),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Left Turns", icon: "arrow.turn.up.left", grade: "A+", description: "Excellent control and speed"),
                        ManeuverAnalysis(name: "Right Turns", icon: "arrow.turn.up.right", grade: "A", description: "Good signal usage"),
                        ManeuverAnalysis(name: "Parking", icon: "p.circle", grade: "A-", description: "Well-centered in the space")
                    ]
                ),
                DriveHistory(
                    date: "June 14, 8:10 AM",
                    distance: 15.2,
                    score: 76,
                    performanceBreakdown: PerformanceBreakdown(control: 80, speed: 70, aware: 81, follow: 75, smooth: 72),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Following Distance", icon: "car.2", grade: "C+", description: "Followed too closely in traffic"),
                        ManeuverAnalysis(name: "Speeding", icon: "speedometer", grade: "C", description: "Exceeded speed limit in a school zone")
                    ]
                ),
                DriveHistory(
                    date: "June 12, 6:30 PM",
                    distance: 22.0,
                    score: 88,
                    performanceBreakdown: PerformanceBreakdown(control: 91, speed: 85, aware: 90, follow: 89, smooth: 84),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Highway Merging", icon: "road.lanes.curved.right", grade: "B+", description: "Good speed matching, slightly late signal")
                    ]
                ),
                DriveHistory(
                    date: "June 11, 4:00 PM",
                    distance: 5.5,
                    score: 95,
                    performanceBreakdown: PerformanceBreakdown(control: 99, speed: 94, aware: 96, follow: 95, smooth: 97),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Stop Signs", icon: "hand.raised", grade: "A+", description: "Flawless execution of 3-second stops.")
                    ]
                ),
                DriveHistory(
                    date: "June 10, 3:15 PM",
                    distance: 10.8,
                    score: 82,
                    performanceBreakdown: PerformanceBreakdown(control: 85, speed: 80, aware: 84, follow: 81, smooth: 79),
                    maneuverAnalyses: [
                         ManeuverAnalysis(name: "Smoothness", icon: "wind", grade: "B-", description: "Some jerky braking and acceleration noted.")
                    ]
                ),
                DriveHistory(
                    date: "June 8, 11:00 AM",
                    distance: 18.1,
                    score: 89,
                    performanceBreakdown: PerformanceBreakdown(control: 92, speed: 88, aware: 90, follow: 91, smooth: 86),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Intersection", icon: "square.on.square", grade: "A-", description: "Good awareness at intersections.")
                    ]
                ),
                DriveHistory(
                    date: "June 7, 9:00 PM",
                    distance: 9.3,
                    score: 81,
                    performanceBreakdown: PerformanceBreakdown(control: 88, speed: 75, aware: 82, follow: 85, smooth: 80),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Night Driving", icon: "moon.stars", grade: "B", description: "Good headlight usage, slightly hesitant on turns.")
                    ]
                ),
                 DriveHistory(
                    date: "June 6, 1:00 PM",
                    distance: 7.2,
                    score: 93,
                    performanceBreakdown: PerformanceBreakdown(control: 95, speed: 92, aware: 94, follow: 93, smooth: 91),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Parking", icon: "p.circle", grade: "A", description: "Confident and centered parking.")
                    ]
                ),
                DriveHistory(
                    date: "June 5, 5:30 PM",
                    distance: 14.8,
                    score: 79,
                    performanceBreakdown: PerformanceBreakdown(control: 83, speed: 74, aware: 80, follow: 78, smooth: 77),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Following Distance", icon: "car.2", grade: "C", description: "Consistently followed too closely behind trucks.")
                    ]
                )
            ]
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
                DriveHistory(
                    date: "June 17, 4:00 PM",
                    distance: 11.2,
                    score: 96,
                    performanceBreakdown: PerformanceBreakdown(control: 98, speed: 95, aware: 97, follow: 96, smooth: 95),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Stop Signs", icon: "hand.raised", grade: "A+", description: "Perfect 3-second stops at every sign."),
                        ManeuverAnalysis(name: "Awareness", icon: "eye", grade: "A", description: "Consistently scanned mirrors and blind spots.")
                    ]
                ),
                DriveHistory(
                    date: "June 16, 3:00 PM",
                    distance: 5.4,
                    score: 95,
                    performanceBreakdown: PerformanceBreakdown(control: 94, speed: 98, aware: 93, follow: 96, smooth: 95),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Speed Control", icon: "speedometer", grade: "A", description: "Maintained consistent speed on all roads."),
                        ManeuverAnalysis(name: "Following Distance", icon: "car.2", grade: "A", description: "Excellent following distance at all times.")
                    ]
                ),
                DriveHistory(
                    date: "June 14, 6:00 PM",
                    distance: 11.2,
                    score: 90,
                    performanceBreakdown: PerformanceBreakdown(control: 92, speed: 91, aware: 88, follow: 94, smooth: 90),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Parking", icon: "p.circle", grade: "A", description: "Excellent parallel parking maneuver")
                    ]
                ),
                DriveHistory(
                    date: "June 13, 1:20 PM",
                    distance: 7.8,
                    score: 88,
                    performanceBreakdown: PerformanceBreakdown(control: 90, speed: 84, aware: 89, follow: 92, smooth: 85),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Lane Changes", icon: "arrow.left.arrow.right", grade: "B+", description: "All checks performed, slightly hesitant")
                    ]
                ),
                 DriveHistory(
                    date: "June 11, 7:00 AM",
                    distance: 16.5,
                    score: 94,
                    performanceBreakdown: PerformanceBreakdown(control: 95, speed: 92, aware: 96, follow: 93, smooth: 94),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Awareness", icon: "eye", grade: "A", description: "Excellent scanning of surroundings in heavy traffic.")
                    ]
                ),
                DriveHistory(
                    date: "June 10, 5:00 PM",
                    distance: 8.1,
                    score: 91,
                    performanceBreakdown: PerformanceBreakdown(control: 93, speed: 90, aware: 92, follow: 91, smooth: 89),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Left Turns", icon: "arrow.turn.up.left", grade: "A-", description: "Good control, waited for safe gaps.")
                    ]
                ),
                DriveHistory(
                    date: "June 9, 2:30 PM",
                    distance: 25.3,
                    score: 92,
                    performanceBreakdown: PerformanceBreakdown(control: 94, speed: 90, aware: 93, follow: 91, smooth: 92),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Highway Driving", icon: "road.lanes", grade: "A-", description: "Excellent lane discipline and speed control.")
                    ]
                ),
                DriveHistory(
                    date: "June 7, 6:45 PM",
                    distance: 4.8,
                    score: 98,
                    performanceBreakdown: PerformanceBreakdown(control: 99, speed: 97, aware: 98, follow: 98, smooth: 99),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "All-Way Stop", icon: "person.3", grade: "A+", description: "Perfectly yielded right-of-way.")
                    ]
                ),
                DriveHistory(
                    date: "June 6, 8:00 PM",
                    distance: 12.1,
                    score: 93,
                    performanceBreakdown: PerformanceBreakdown(control: 94, speed: 92, aware: 95, follow: 91, smooth: 93),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Night Driving", icon: "moon.stars", grade: "A-", description: "Handled glare well, confident maneuvers.")
                    ]
                ),
                 DriveHistory(
                    date: "June 4, 3:00 PM",
                    distance: 10.2,
                    score: 94,
                    performanceBreakdown: PerformanceBreakdown(control: 95, speed: 93, aware: 95, follow: 94, smooth: 92),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Right Turns", icon: "arrow.turn.up.right", grade: "A", description: "Good turning radius and speed.")
                    ]
                ),
                DriveHistory(
                    date: "June 2, 9:00 AM",
                    distance: 19.8,
                    score: 91,
                    performanceBreakdown: PerformanceBreakdown(control: 93, speed: 90, aware: 92, follow: 90, smooth: 89),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Lane Keeping", icon: "arrow.up.and.down", grade: "A-", description: "Consistently centered in lane.")
                    ]
                )
            ]
        )
    ]
}
