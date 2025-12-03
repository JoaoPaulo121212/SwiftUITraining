//
//  SwiftUITrainingApp.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 02/12/25.
//

import SwiftUI
import SwiftData

@main
struct SwiftUITrainingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TaskItem.self)
    }
}
