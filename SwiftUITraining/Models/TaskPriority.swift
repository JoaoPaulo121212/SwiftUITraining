//
//  TaskPriority.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 06/12/25.
//

import SwiftUI

enum TaskPriority: String, Codable, CaseIterable {
    
    case low = "Baixa"
    case medium = "Média"
    case high = "Alta"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .red
        }
    }
    var icon: String {
        switch self {
        case .low: return "arrow.down"
        case .medium: return "minus"
        case .high: return "exclamationmark.3"
        }
    }
}
