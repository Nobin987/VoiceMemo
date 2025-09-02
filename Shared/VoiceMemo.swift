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
        getDocumentsDirectory().appendingPathComponent(fileName)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    var durationString: String {
        let mins = Int(duration) / 60
        let secs = Int(duration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}