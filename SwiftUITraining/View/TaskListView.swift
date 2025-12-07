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
    @State private var searchText: String = ""
    
    var filteredTasks: [TaskItem] {
        if searchText.isEmpty {
            return tasks
        } else{
            return tasks.filter { task in
                task.name.localizedStandardContains(searchText) ||
                task.details.localizedStandardContains(searchText)
            }
        }
    }
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredTasks) { task in
                    TaskRowView(task: task) {
                        viewModel.toggleTaskCompletion(task)
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.toggleHideTask(task, context: modelContext)
                        } label: {
                            Label(showHidden ? "Mostrar" : "Ocultar", systemImage: showHidden ? "eye" : "eye.slash")
                        }
                        .tint(showHidden ? .blue : .orange)
                    }
                }
                .onDelete { offsets in
                    viewModel.deleteTask(offsets: offsets, tasks: filteredTasks, context: modelContext)
                }
            }
            .navigationTitle(showHidden ? "Itens Ocultos" : "TaskManager")
            .searchable(text: $searchText, prompt: "Buscar tarefa...")
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
