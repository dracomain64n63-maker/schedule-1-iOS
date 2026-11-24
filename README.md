# Schedule 1 — Unreal Engine Mobile + Controller Starter

**Engine target:** Unreal Engine 5.8.

This is a C++ starter project for a landscape-oriented mobile first-person prototype. It is not a finished game or prebuilt IPA.

## Added in this revision
- Original boot menu with Play, Settings placeholder, and Quit
- Controller connection polling
- Mobile virtual controls hidden when a controller is connected
- Touching the screen re-enables mobile controls; subsequent gamepad input hides them again
- Green on-screen controller-connected indicator
- PlayStation-compatible generic gamepad mappings
- Reusable alternating red/blue police emergency-light actor

## Controls

### Mobile
- Left virtual joystick: move
- Right virtual joystick: look
- Touch screen: re-enable virtual controls while a controller is connected
- Landscape orientation

### Controller
- Left stick: move
- Right stick: look
- Cross / A: jump
- Square / X: interact
- Other standard gamepad inputs are recognized as controller activity

### Editor keyboard and mouse
- W / A / S / D: move
- Mouse: look
- Space: jump
- E: interact

## Setup and test
1. Install Unreal Engine 5.8 and its C++ toolchain on a supported development computer.
2. Extract the ZIP and open `Schedule1.uproject`.
3. Let Unreal generate project files and compile the C++ module.
4. Create a level named `Prototype` and save it under `Content/Maps/`.
5. In **Edit → Project Settings → Maps & Modes**, set `Prototype` as both Editor Startup Map and Game Default Map.
6. Add a floor and a few cubes. Ensure interactable cubes block the Visibility trace channel.
7. Add an instance of `Schedule1PoliceLights` to a level or attach its components to a police vehicle blueprint.
8. Test mobile touch input and a connected controller on target hardware.

## Important limitations
- This archive contains starter source and configuration only. It does not include Unreal Engine, art assets, a finished city, inventory/economy/save systems, a finished settings screen, or packaged iOS output.
- The boot menu is an original simple prototype menu, not a recreation of another game's exact interface.
- The Settings button is currently a placeholder.
- Controller connection detection and touch-interface switching must be compiled and tested on the target Unreal version/device. Controller hardware lighting cannot be changed by the game; the green indicator is an in-game status label.
- The police-light actor only supplies alternating red/blue light effects; it is not yet connected to a police AI or alert system.
- iOS packaging must be performed with a correctly configured Unreal iOS toolchain. This archive does not include a one-click IPA build workflow.

## Project identity
Project name: Schedule 1
Project folder: Schedule1
