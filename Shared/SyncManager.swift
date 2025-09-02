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
    
    // MARK: - Sync a single memo
    func syncMemo(_ memo: VoiceMemo) {
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        
        // Send metadata
        let memoData: [String: Any] = [
            "id": memo.id.uuidString,
            "title": memo.title,
            "date": memo.date,
            "duration": memo.duration,
            "fileName": memo.fileName
        ]
        
        session.transferUserInfo(["memo": memoData])
        
        // Send audio file
        if FileManager.default.fileExists(atPath: memo.fileURL.path) {
            session.transferFile(memo.fileURL, metadata: ["id": memo.id.uuidString])
        }
    }
    
    func syncAllMemos(_ memos: [VoiceMemo]) {
        for memo in memos {
            syncMemo(memo)
        }
    }
    
    // MARK: - Delete memo
    func deleteMemo(id: UUID) {
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        session.transferUserInfo(["delete": id.uuidString])
    }
}

extension SyncManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
    
    // MARK: - Receiving Metadata
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        DispatchQueue.main.async {
            if let memoData = userInfo["memo"] as? [String: Any] {
                NotificationCenter.default.post(name: NSNotification.Name("ReceivedMemo"), object: memoData)
            } else if let deleteId = userInfo["delete"] as? String {
                NotificationCenter.default.post(name: NSNotification.Name("DeleteMemo"), object: deleteId)
            }
        }
    }
    
    // MARK: - Receiving Audio File
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        DispatchQueue.main.async {
            if let id = file.metadata?["id"] as? String,
               let data = try? Data(contentsOf: file.fileURL) {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ReceivedAudio"),
                    object: ["id": id, "data": data]
                )
            }
        }
    }
}
