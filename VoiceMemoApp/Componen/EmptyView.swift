//
//  EmptyView.swift
//  VoiceMemoApp
//
//  Created by Muhammad Naeem Akram on 02/09/2025.
//

import SwiftUI

struct EmptyView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Voice Memos")
                .font(.title2)
            
            Text("Tap the microphone to record")
                .foregroundColor(.secondary)
        }
    }
}
