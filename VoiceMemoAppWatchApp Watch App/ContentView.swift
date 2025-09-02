//
//  ContentView.swift
//  VoiceMemoAppWatchApp Watch App
//
//  Created by Nobin Nepolian on 02/09/2025.
//

// MARK: - ContentView.swift (watchOS Main View)

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        VStack {
            if audioManager.voiceMemos.isEmpty {
                EmptyView()
            } else {
                MemoList()
            }
            
            RecordButton()
        }
        .onAppear {
            _ = SyncManager.shared
        }
        .environmentObject(audioManager)
    }
}

struct EmptyView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.circle")
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            Text("No Memos")
                .font(.headline)
            
            Text("Tap mic to record")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct MemoList: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack {
            Text("Voice Memos")
                .font(.headline)
                .padding(.bottom, 4)
            
            List {
                ForEach(audioManager.voiceMemos.prefix(5)) { memo in // Limit for watch
                    MemoRow(memo: memo)
                        .listRowInsets(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                }
                .onDelete(perform: deleteMemos)
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private func deleteMemos(offsets: IndexSet) {
        for index in offsets {
            _ = audioManager.voiceMemos.prefix(5).firstIndex { memo in
                memo.id == Array(audioManager.voiceMemos.prefix(5))[index].id
            }
            if let actualIndex = audioManager.voiceMemos.firstIndex(where: { $0.id == Array(audioManager.voiceMemos.prefix(5))[index].id }) {
                audioManager.deleteMemo(audioManager.voiceMemos[actualIndex])
            }
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
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(memo.title)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text(memo.durationString)
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            Text(memo.dateString)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Button(action: {
                if isPlaying {
                    audioManager.stopPlaying()
                } else {
                    audioManager.playMemo(memo)
                }
            }) {
                HStack(spacing: 2) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.caption)
                    Text(isPlaying ? "Playing" : "Play")
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct RecordButton: View {
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 4) {
            if audioManager.isRecording {
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 4, height: 4)
                    Text("Recording")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                
                Text(formatTime(audioManager.recordingTime))
                    .font(.caption2)
                    .fontWeight(.medium)
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
                        .frame(width: 44, height: 44)
                    
                    if audioManager.isRecording {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
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
