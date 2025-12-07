//
//  ContentView.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 02/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \TaskItem.dueDate) private var allTasks: [TaskItem]
    
    var body: some View {
        TabView {

            TaskListView(
                tasks: allTasks.filter { !$0.isHidden },
                showHidden: false
            )
            .tabItem {
                Label("Tarefas", systemImage: "checklist")
            }
            
            HiddenTasksView(
                hiddenTasks: allTasks.filter { $0.isHidden }
            )
                .tabItem {
                    Label("Ocultas", systemImage: "eye.slash")
                }
        }
        .onAppear {
            NotificationManager.shared.requestPermission()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskItem.self)
}
