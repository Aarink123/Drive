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
                DriveHistory(date: "June 16, 4:30 PM", distance: 12.3, score: 85),
                DriveHistory(date: "June 15, 5:00 PM", distance: 8.7, score: 92),
                DriveHistory(date: "June 14, 2:15 PM", distance: 20.1, score: 78)
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
                DriveHistory(date: "June 16, 3:00 PM", distance: 5.4, score: 95),
                DriveHistory(date: "June 14, 6:00 PM", distance: 11.2, score: 90),
                DriveHistory(date: "June 13, 1:20 PM", distance: 7.8, score: 88)
            ]
        )
    ]
}
