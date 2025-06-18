//
//  testingTIeApp.swift
//  testingTIe
//
//  Created by Aarin Karamchandani on 3/18/25.
//

import SwiftUI

   @main
   struct DriveQuestApp: App {
       @StateObject private var appData = AppData()

       var body: some Scene {
           WindowGroup {
               LoginView1() // Replace with your initial view
                   .environmentObject(appData)
           }
       }
   }
