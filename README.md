# Schedule 1 — iOS Prototype

A private, personal-use first-person 3D business-simulation prototype for iOS, built with Unity 6.

## Included
- Unity project folder structure
- First-person controller with keyboard/mouse support in Editor
- Basic mobile look and movement input hooks
- Interactable object framework
- Simple interaction raycast
- Prototype game manager
- GitHub Actions workflow that exports an iOS Xcode project on a macOS runner

This is a starter prototype project. It does not include proprietary game code, maps, characters, or assets from any existing game.

## Requirements
- Unity 6 (install the iOS Build Support module)
- A GitHub repository
- A Unity license suitable for CI
- For a signed IPA: an Apple Developer signing certificate and provisioning profile

## Open in Unity
1. Download and extract this repository.
2. In Unity Hub, choose **Add > Add project from disk** and select this folder.
3. Open with a Unity 6 editor version.
4. Create a scene named `Main` under `Assets/Scenes`.
5. Add a Plane, a few Cube buildings, and a Capsule for the player.
6. Add a CharacterController component to the player Capsule.
7. Add `FirstPersonController.cs` to the player.
8. Add a Camera as a child of the player at local position `(0, 1.6, 0)` and assign it to the controller's `playerCamera` field.
9. Add `PrototypeGameManager.cs` to an empty GameObject.
10. Save the scene as `Assets/Scenes/Main.unity` and add it to Build Settings.

## Input
- Editor: WASD to move, mouse to look, E to interact.
- Mobile: connect on-screen joystick/look UI to `SetMoveInput` and `SetLookInput` on `FirstPersonController`; call `TryInteract` from an interaction button.

The included controller intentionally keeps mobile UI minimal so it can be designed for the actual target screen later.

## GitHub Actions setup
Add a repository secret named `UNITY_LICENSE` containing the Unity license XML. The workflow exports an Xcode project and uploads it as an artifact.

The first workflow does **not** claim to produce a signed IPA. An iOS Xcode project must be signed with an Apple certificate and provisioning profile before it can become an installable IPA. We can add that signing stage after the Unity export succeeds.

## Project settings to check
In Unity:
- File > Build Settings > iOS > Switch Platform
- Player Settings > Other Settings > Bundle Identifier: set a unique identifier
- Set a supported iOS minimum version
- Set orientation and icon later

## Prototype milestone
The first milestone is a small test environment with:
- First-person walking and looking
- A small street and several placeholder buildings
- One interactable business terminal
- A basic money display
- Peaceful mode as the default (no police system)


## Project title
The project display name is **Schedule 1**. The repository folder can be named `schedule-1-ios`.
