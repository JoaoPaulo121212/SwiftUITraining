//
//  TaskListView.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 05/12/25.
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    
    let tasks: [TaskItem]
    let showHidden: Bool
    
    @State private var viewModel = TaskListViewModel()
    @State private var showingAddTaskSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(tasks) { task in
                    TaskRowView(task: task) {
                        viewModel.toggleTaskCompletion(task)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.toggleHideTask(task)
                        } label: {
                            Label(showHidden ? "Mostrar" : "Ocultar", systemImage: showHidden ? "eye" : "eye.slash")
                        }
                        .tint(showHidden ? .blue : .orange)
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteTask(offsets: offsets, tasks: tasks, context: modelContext)
                }
            }
            .navigationTitle(showHidden ? "Itens Ocultos" : "TaskManager")
            .toolbar {
                if !showHidden && !viewModel.deletedTasksHistory.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.restoreLastTask(context: modelContext)
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                        }
                    }
                }
                
                if !showHidden {
                    ToolbarItem(placement: .topBarLeading) {
                        Button { showingAddTaskSheet = true } label: {
                            Label("Adicionar", systemImage: "plus.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskSheet) {
                AddTaskView()
            }
        }
    }
}
