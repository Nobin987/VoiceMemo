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
                .onDelete { offsets in
                    offsets.forEach { index in
                        let memo = audioManager.voiceMemos[index]
                        audioManager.voiceMemos.remove(at: index)
                        try? FileManager.default.removeItem(at: memo.fileURL)
                        audioManager.saveMemos()
                    }
                }
            }
            .listStyle(PlainListStyle())
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

struct WaveformView: View {
    @Binding var level: Float
    let barCount = 20
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                Capsule()
                    .fill(Color.blue)
                    .frame(width: 3, height: barHeight(for: index))
                    .animation(.easeOut(duration: 0.05), value: level)
            }
        }
        .frame(height: 50)
        .padding(.horizontal)
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let factor = CGFloat.random(in: 0.3...1.0)
        return max(2, CGFloat(level) * 50 * factor)
    }
}


#Preview {
    ContentView()
}
