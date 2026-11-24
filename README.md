# Schedule 1 — Swift / RealityKit prototype

This is a native iOS starter project using SwiftUI and RealityKit.

## What is included
- Original title menu with Play and Settings
- Basic 3D city-block scene
- First-person camera position and drag-to-look
- On-screen movement controls
- Basic property interaction and placeholder cash balance
- Landscape orientation
- GitHub Actions workflow that builds an **iOS Simulator app**

## Important limitations
- This is a prototype foundation, not a complete game.
- The city is made from simple placeholder geometry.
- Business management, employees, economy progression, save data, missions, police systems, difficulty modes, and production-ready art are not implemented.
- Controller connection detection is included, but full controller movement/button mapping is not implemented yet.
- The workflow produces a simulator `.app` archive, **not an installable device IPA**.
- The project has not been compiled or run in Xcode in this environment. Run the GitHub Actions workflow and review its build log before treating it as verified.

## Build
Open `Schedule1.xcodeproj` in Xcode 16 or later, or run the included GitHub Actions workflow.
