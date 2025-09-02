//
//  AudioManager.swift
//  VoiceMemoApp
//
//  Created by Nobin Nepolian on 02/09/2025.
//


// MARK: - AudioManager.swift (Shared - Add to BOTH targets)

import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var voiceMemos: [VoiceMemo] = []
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var pendingAudioData: Data?
    private var pendingMemoData: [String: Any]?
    
    override init() {
        super.init()
        setupAudio()
        loadMemos()
        setupNotifications()
    }
    
    private func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Audio setup failed: \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ReceivedMemo"), object: nil, queue: .main) { notification in
            if let data = notification.object as? [String: Any] {
                self.pendingMemoData = data
                self.checkAndCreateMemo()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ReceivedAudio"), object: nil, queue: .main) { notification in
            if let data = notification.object as? Data {
                self.pendingAudioData = data
                self.checkAndCreateMemo()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DeleteMemo"), object: nil, queue: .main) { notification in
            if let idString = notification.object as? String,
               let id = UUID(uuidString: idString) {
                self.deleteMemo(id: id)
            }
        }
    }
    
    private func checkAndCreateMemo() {
        guard let memoData = pendingMemoData,
              let audioData = pendingAudioData else { return }
        
        // Create memo from received data
        if let idString = memoData["id"] as? String,
           let id = UUID(uuidString: idString),
           let title = memoData["title"] as? String,
           let date = memoData["date"] as? Date,
           let duration = memoData["duration"] as? TimeInterval,
           let fileName = memoData["fileName"] as? String {
            
            let memo = VoiceMemo(title: title, date: date, duration: duration, fileName: fileName)
            
            // Save audio file
            try? audioData.write(to: memo.fileURL)
            
            // Add to list if not exists
            if !voiceMemos.contains(where: { $0.id == id }) {
                voiceMemos.insert(memo, at: 0)
                saveMemos()
            }
        }
        
        // Clear pending data
        pendingMemoData = nil
        pendingAudioData = nil
    }
    
    func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    self.performStartRecording()
                }
            }
        }
    }
    
    private func performStartRecording() {
        let fileName = "memo_\(Date().timeIntervalSince1970).m4a"
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            isRecording = true
            recordingTime = 0
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.recordingTime += 0.1
            }
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        
        let duration = recordingTime
        let fileName = audioRecorder?.url.lastPathComponent ?? ""
        
        isRecording = false
        recordingTime = 0
        
        // Create new memo
        let memo = VoiceMemo(
            title: "Memo \(voiceMemos.count + 1)",
            date: Date(),
            duration: duration,
            fileName: fileName
        )
        
        voiceMemos.insert(memo, at: 0)
        saveMemos()
        
        // Sync to other device
        SyncManager.shared.syncMemo(memo)
    }
    
    func playMemo(_ memo: VoiceMemo) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: memo.fileURL)
            audioPlayer?.play()
            isPlaying = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + memo.duration) {
                self.isPlaying = false
            }
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func deleteMemo(_ memo: VoiceMemo) {
        voiceMemos.removeAll { $0.id == memo.id }
        try? FileManager.default.removeItem(at: memo.fileURL)
        saveMemos()
        SyncManager.shared.deleteMemo(id: memo.id)
    }
    
    private func deleteMemo(id: UUID) {
        if let memo = voiceMemos.first(where: { $0.id == id }) {
            voiceMemos.removeAll { $0.id == id }
            try? FileManager.default.removeItem(at: memo.fileURL)
            saveMemos()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveMemos() {
        if let data = try? JSONEncoder().encode(voiceMemos) {
            UserDefaults.standard.set(data, forKey: "memos")
        }
    }
    
    private func loadMemos() {
        if let data = UserDefaults.standard.data(forKey: "memos"),
           let memos = try? JSONDecoder().decode([VoiceMemo].self, from: data) {
            voiceMemos = memos.filter { FileManager.default.fileExists(atPath: $0.fileURL.path) }
        }
    }
}
