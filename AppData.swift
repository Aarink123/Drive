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
                averageSpeed: 28.5,
                distanceDrove: 12.3,
                hardBraking: 3,
                rapidAcceleration: 2,
                speedingInstances: 1,
                safetyRating: .moderate,
                driveDuration: 45,
                totalHoursDriven: 25.5
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
                averageSpeed: 25.2,
                distanceDrove: 8.7,
                hardBraking: 1,
                rapidAcceleration: 0,
                speedingInstances: 0,
                safetyRating: .safe,
                driveDuration: 32,
                totalHoursDriven: 35.2
            ),
            recentDriveScore: 92,
            weekScore: 88,
            monthScore: 85,
            driveHistory: [
                DriveHistory(
                    date: "June 16, 3:00 PM",
                    distance: 5.4,
                    score: 95,
                    performanceBreakdown: PerformanceBreakdown(control: 94, speed: 98, aware: 93, follow: 96, smooth: 95),
                    maneuverAnalyses: [
                        ManeuverAnalysis(name: "Stop Signs", icon: "hand.raised", grade: "A", description: "Came to a complete stop each time"),
                        ManeuverAnalysis(name: "Following Distance", icon: "car.2", grade: "A-", description: "Maintained good distance, slightly close once")
                    ]
                )
            ]
        )
    ]
}
