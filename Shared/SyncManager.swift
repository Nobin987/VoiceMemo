//
//  SyncManager.swift
//  VoiceMemoApp
//
//  Created by Nobin Nepolian on 02/09/2025.
//


import Foundation
import WatchConnectivity

class SyncManager: NSObject, ObservableObject {
    static let shared = SyncManager()
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func syncMemo(_ memo: VoiceMemo) {
        guard WCSession.default.isReachable else { return }
        
        // Send memo metadata
        let memoData: [String: Any] = [
            "id": memo.id.uuidString,
            "title": memo.title,
            "date": memo.date,
            "duration": memo.duration,
            "fileName": memo.fileName
        ]
        
        WCSession.default.sendMessage(["memo": memoData], replyHandler: nil)
        
        // Send audio file
        if let audioData = try? Data(contentsOf: memo.fileURL) {
            WCSession.default.sendMessageData(audioData, replyHandler: nil)
        }
    }
    
    func syncAllMemos(_ memos: [VoiceMemo]) {
        for memo in memos {
            syncMemo(memo)
        }
    }
    
    func deleteMemo(id: UUID) {
        guard WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["delete": id.uuidString], replyHandler: nil)
    }
}

extension SyncManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let memoData = message["memo"] as? [String: Any] {
                self.handleReceivedMemo(memoData)
            } else if let deleteId = message["delete"] as? String {
                NotificationCenter.default.post(name: NSNotification.Name("DeleteMemo"), object: deleteId)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        // Handle received audio file
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("ReceivedAudio"), object: messageData)
        }
    }
    
    private func handleReceivedMemo(_ data: [String: Any]) {
        NotificationCenter.default.post(name: NSNotification.Name("ReceivedMemo"), object: data)
    }
}