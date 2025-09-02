//
//  ContentView.swift
//  VoiceMemoApp
//
//  Created by Nobin Nepolian on 02/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if audioManager.voiceMemos.isEmpty {
                    EmptyView()
                } else {
                    MemoList()
                }
                
                RecordButton()
            }
            .navigationTitle("Voice Memos")
            .environmentObject(audioManager)
        }
        .onAppear {
            _ = SyncManager.shared // Initialize sync
        }
    }
}

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

struct MemoList: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        List {
            ForEach(audioManager.voiceMemos) { memo in
                MemoRow(memo: memo)
            }
            .onDelete(perform: deleteMemos)
        }
    }
    
    private func deleteMemos(offsets: IndexSet) {
        for index in offsets {
            audioManager.deleteMemo(audioManager.voiceMemos[index])
        }
    }
}

struct MemoRow: View {
    let memo: VoiceMemo
    @EnvironmentObject var audioManager: AudioManager
    var isPlaying: Bool {
        audioManager.currentlyPlayingID == memo.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(memo.title)
                    .font(.headline)
                Spacer()
                Text(memo.durationString)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            Text(memo.dateString)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(action: {
                if isPlaying {
                    audioManager.stopPlaying()
                } else {
                    audioManager.playMemo(memo)
                }
            }) {
                HStack {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    Text(isPlaying ? "Playing" : "Play")
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RecordButton: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            if audioManager.isRecording {
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

#Preview {
    ContentView()
}



