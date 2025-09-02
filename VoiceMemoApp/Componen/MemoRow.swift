//
//  MemoRow.swift
//  VoiceMemoApp
//
//  Created by Muhammad Naeem Akram on 02/09/2025.
//

import SwiftUI

struct MemoRow: View {
    let memo: VoiceMemo
    @EnvironmentObject var audioManager: AudioManager
    
    var isPlaying: Bool { audioManager.currentlyPlayingID == memo.id }
    
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
                if isPlaying { audioManager.stopPlaying() }
                else { audioManager.playMemo(memo) }
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
