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
    @Published var recordingTime: TimeInterval = 0
    @Published var voiceMemos: [VoiceMemo] = []
    @Published var currentlyPlayingID: UUID? = nil
    @Published var audioLevel: Float = 0.0  // For waveform
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    
    override init() {
        super.init()
        setupAudio()
        loadMemos()
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
    
    func startRecording() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted { self.performStartRecording() }
                    else { print("Recording permission denied") }
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted { self.performStartRecording() }
                    else { print("Recording permission denied") }
                }
            }
        }
    }
    
    func performStartRecording() {
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
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            isRecording = true
            recordingTime = 0
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                guard let recorder = self.audioRecorder else { return }
                
                self.recordingTime += 0.05
                recorder.updateMeters()
                
                // Normalize audio level 0..1
                let level = recorder.averagePower(forChannel: 0)
                let minLevel: Float = -50
                let maxLevel: Float = 0
                let normalized = max(0, (level - minLevel) / (maxLevel - minLevel))
                self.audioLevel = normalized
            }
        } catch {
            print("Recording failed: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        let duration = recordingTime
        let fileName = audioRecorder?.url.lastPathComponent ?? ""
        
        isRecording = false
        recordingTime = 0
        audioLevel = 0.0
        
        // Create new memo
        let memo = VoiceMemo(title: "Memo \(voiceMemos.count + 1)",
                             date: Date(),
                             duration: duration,
                             fileName: fileName)
        voiceMemos.insert(memo, at: 0)
        saveMemos()
    }
    
    func playMemo(_ memo: VoiceMemo) {
        do {
            let session = AVAudioSession.sharedInstance()
            
            #if os(iOS)
            // On iOS, play through speaker
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
            #elseif os(watchOS)
            // On watchOS, default options only
            try session.setCategory(.playAndRecord)
            #endif
            
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: memo.fileURL)
            audioPlayer?.play()
            currentlyPlayingID = memo.id
            
            // Reset playing state after the memo duration
            DispatchQueue.main.asyncAfter(deadline: .now() + memo.duration) {
                if self.currentlyPlayingID == memo.id {
                    self.currentlyPlayingID = nil
                }
            }
        } catch {
            print("Playback failed: \(error)")
        }
    }

    
    func stopPlaying() {
        audioPlayer?.stop()
        currentlyPlayingID = nil
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveMemos() {
        if let data = try? JSONEncoder().encode(voiceMemos) {
            UserDefaults.standard.set(data, forKey: "memos")
        }
    }
    
    func loadMemos() {
        if let data = UserDefaults.standard.data(forKey: "memos"),
           let memos = try? JSONDecoder().decode([VoiceMemo].self, from: data) {
            voiceMemos = memos.filter { FileManager.default.fileExists(atPath: $0.fileURL.path) }
        }
    }
}
