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
                    VStack(spacing: 20) {
                        Image(systemName: "mic.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("No Voice Memos")
                            .font(.title2)
                        Text("Tap the microphone to record")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(audioManager.voiceMemos) { memo in
                            MemoRow(memo: memo)
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
                }
                
                RecordButton()
            }
            .navigationTitle("Voice Memos")
            .environmentObject(audioManager)
        }
    }
}

#Preview {
    ContentView()
}



