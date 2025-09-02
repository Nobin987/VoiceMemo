//
//  VoiceMemo.swift
//  VoiceMemoApp
//
//  Created by Nobin Nepolian on 02/09/2025.
//


// MARK: - VoiceMemo.swift (Shared - Add to BOTH targets)

import Foundation

struct VoiceMemo: Identifiable, Codable {
    let id = UUID()
    let title: String
    let date: Date
    let duration: TimeInterval
    let fileName: String
    
    var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }
    
    var durationString: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
