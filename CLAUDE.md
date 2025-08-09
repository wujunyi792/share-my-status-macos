# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

This is a standard Swift Xcode project for a macOS application.

- **Build the application**:
  ```bash
  xcodebuild -scheme "Share My Status" build
  ```

- **Run tests**:
  ```bash
  xcodebuild -scheme "Share My Status" test
  ```

- **Clean the build folder**:
  ```bash
  xcodebuild -scheme "Share My Status" clean
  ```

## Architecture

This is a SwiftUI-based macOS application designed to share the user's currently playing music status.

- **Entry Point**: `Share_My_StatusApp.swift` is the main entry point. It sets up the primary application window (`WindowGroup`) and the system menu bar icon (`MenuBarExtra`).
- **Core ViewModels**:
    - `NowPlayingViewModel.swift`: This is the core of the application's logic. It's responsible for fetching the current music track from the system, managing the history of shared statuses, and preparing data for the views.
- **Data Models**:
    - `MusicData.swift`: Defines the data structure for a music track (e.g., title, artist, album).
    - `Settings.swift`: Manages user-configurable settings, such as server endpoints or authentication details.
- **Views (SwiftUI)**:
    - `ContentView.swift`: The main UI presented in the application window.
    - `MenuBarView.swift`: The compact UI that appears when clicking the app's icon in the macOS menu bar.
    - `SettingsView.swift`: The user interface for modifying application settings.
    - `ReportHistoryView.swift`: Displays a list of previously shared statuses.
- **Services**:
    - `NetworkService.swift`: Handles all networking tasks, specifically sending the current music status to a remote server.
    - **MediaRemoteAdapter**: The application uses a pre-compiled `MediaRemoteAdapter.framework` located in the `Share My Status/Build_Dependencies/` directory. This framework is responsible for interfacing with the macOS `MediaRemote` service to get information about the currently playing song.