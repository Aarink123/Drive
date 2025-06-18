//
//  AppData.swift
//  DriveQuest
//
//  Created by Aarin Karamchandani on 6/17/25.
//


//
//  AppData.swift
//  DriveQuest
//
//  Created by Aarin Karamchandani on 6/11/25.
//

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
                driveDuration: 45
            ),
            recentDriveScore: 85,
            weekScore: 78,
            monthScore: 82
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
                driveDuration: 32
            ),
            recentDriveScore: 92,
            weekScore: 88,
            monthScore: 85
        )
    ]
}
