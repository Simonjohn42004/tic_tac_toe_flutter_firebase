# 🎮 Tic Tac Toe - Flutter App

A modern Flutter-based implementation of the classic **Tic Tac Toe** game with advanced rules and modes:

- 🧑‍🤝‍🧑 Offline Two-Player Mode  
- 🧠 Offline AI Mode using **Minimax with Alpha-Beta Pruning**  
- 🌐 Online Multiplayer Mode via **Firebase Realtime Database**

---

## 📱 Features

### ✅ Offline Two-Player Mode
- Two players can play on the same device.
- Turn-based gameplay with visual indicators.
- Custom Rule: Each player can only have **3 moves on the board at any time**.
- On the 4th move, the **oldest move is removed** automatically.

### 🧠 Offline AI Mode
- Play against a smart AI opponent.
- The AI uses **Minimax with Alpha-Beta Pruning** to evaluate and select optimal moves.
- AI follows the same 3-move limit rule.
- AI avoids placing its move on the cell that's about to be removed on its next turn.

### 🌐 Online Multiplayer Mode
- Create and join rooms using unique room IDs.
- Real-time gameplay using **Firebase Realtime Database**.
- Game board remains inactive until both players are connected.
- The room creator can reset the game.

---

## 🧠 AI Logic

- The AI is implemented using the **Minimax algorithm** with **Alpha-Beta Pruning** to reduce unnecessary computation.
- Evaluates moves based on maximizing wins and minimizing losses.
- Considers the 3-move limit per player.
- Avoids placing symbols on cells that will be removed in the next turn.
- Designed to be challenging and intelligent.

---

## 🛠️ Technologies Used

- **Flutter** – UI development
- **Dart** – Core programming
- **BLoC Pattern** – State management
- **Firebase** – Online multiplayer support
- **Logger** – Debug logging and AI tracing

---

## 📂 Folder Structure

lib/
├── bloc/ # BLoC logic for game and room management
├── models/ # Data models (Game, Player, Room)
├── provider/ # Online & Offline game providers
├── screens/ # UI screens for all modes
├── utils/ # AI logic, logging utilities
└── main.dart # App entry point



---

## 🚀 Getting Started

### Step 1: Clone the repository
``` bash
git clone https://github.com/Simonjohn42004/tic_tac_toe_flutter.git

flutter pub get

flutter run

✅ Ensure Firebase is properly configured with google-services.json (Android) or GoogleService-Info.plist (iOS) for online features to work.

📃 License
This project is licensed under the MIT License.
