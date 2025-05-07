//
//  GoalHitView.swift
//  firstAppHopefullyEmoTune
//
//  Created by Admin on 1/15/25.
//

import SwiftUI

struct GoalHitView: View {
    
    @Binding var shouldShowGoalHit: Bool
    
    var body: some View {
        Text("🎉")
            .scaleEffect(5.0)
            .padding([.bottom, .leading, .trailing], 50)
        Text("You've hit your practice goal for the day! Keep up the good work and come back tomorrow.")
            .padding([.top, .leading, .trailing], 30)
        Button {
            shouldShowGoalHit.toggle()
        } label: {
            Text("Exit")
        }
        .padding([.top, .leading, .trailing], 30)
    }
}

#Preview {
    GoalHitView(shouldShowGoalHit: .constant(true))
}
