# 🎙️ VoiceMemo App

A simple **Voice Memo application** for **iOS** and **watchOS**.  
The app allows you to record voice memos, view a list of saved memos, and sync data in real time between iPhone and Apple Watch using the **WatchConnectivity framework**.

---

## 📱 Features

- Record voice memos on iPhone and Apple Watch  
- View a list of saved memos  
- Real-time sync between iOS and watchOS using WatchConnectivity  
- Lightweight and easy-to-use interface  

---

## 🛠️ Technologies Used

- **SwiftUI** – User interface for iOS and watchOS  
- **AVFoundation** – Audio recording and playback  
- **WatchConnectivity** – Real-time data synchronization  
- **App Groups** – Shared data container for memos  

---

## 📂 Project Structure
VoiceMemoApp/
├── iOSApp/          # iOS app target
├── WatchApp/        # watchOS app target
├── Shared/          # Shared views, models, and data store

---

## 🔄 Data Sync

- Voice memos recorded on either device are stored in a shared location.  
- Using **WatchConnectivity**, changes are instantly reflected on the paired device.  
