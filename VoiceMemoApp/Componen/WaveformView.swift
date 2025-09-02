//
//  WaveformView.swift
//  VoiceMemoApp
//
//  Created by Muhammad Naeem Akram on 02/09/2025.
//

import SwiftUI

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
