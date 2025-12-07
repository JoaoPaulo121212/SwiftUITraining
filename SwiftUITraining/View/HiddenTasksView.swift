//
//  HiddenTasksView.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 05/12/25.
//

import SwiftUI

struct HiddenTasksView: View {
    @State private var viewModel = HiddenTasksViewModel()
    
    let hiddenTasks: [TaskItem]
    
    var body: some View {
        VStack {
            if viewModel.isUnlocked {
                TaskListView(tasks: hiddenTasks, showHidden: true)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.gray)
                    
                    Text("Área Protegida")
                        .font(.title2)
                        .bold()
                    
                    Button("Desbloquear com FaceID") {
                        viewModel.authenticate()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if viewModel.hasError {
                        Text("Falha na autenticação")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
        }
        .onDisappear{
            viewModel.isUnlocked = false
            viewModel.hasError = false
        }
    }
}

#Preview {
    HiddenTasksView(hiddenTasks: [])
}
