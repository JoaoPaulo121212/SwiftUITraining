//
//  HiddenTasksViewModel.swift
//  SwiftUITraining
//
//  Created by Jota Pe on 05/12/25.
//

import LocalAuthentication
import SwiftUI

@Observable
class HiddenTasksViewModel {
    var isUnlocked = false
    var hasError = false
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Desbloquear tarefas ocultas"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                        self.hasError = false
                    } else {
                        self.hasError = true
                    }
                }
            }
        }
    }
}
