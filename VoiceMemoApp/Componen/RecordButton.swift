//
//  RecordButton.swift
//  VoiceMemoApp
//
//  Created by Muhammad Naeem Akram on 02/09/2025.
//

import SwiftUI

struct RecordButton: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            if audioManager.isRecording {
                WaveformView(level: $audioManager.audioLevel)
                
                Text("Recording: \(formatTime(audioManager.recordingTime))")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                if audioManager.isRecording {
                    audioManager.stopRecording()
                } else {
                    audioManager.startRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(audioManager.isRecording ? Color.red : Color.blue)
                        .frame(width: 70, height: 70)
                    
                    if audioManager.isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
