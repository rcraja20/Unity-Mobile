# RC Mobile Studio — Original Engine Track

This repository now starts a separate original engine implementation. It is not Unity source and does not copy Unity proprietary code.

## Step 1 — Engine Core
- C++17 engine core
- Project settings and local project persistence
- Scene object/entity model
- Transform data
- Engine lifecycle
- Renderer abstraction entry point
- Touch event entry points

## Step 2 — Android ARM64 Shell
- Native Android application shell
- OpenGL ES 3 rendering surface
- JNI bridge between Android and native engine
- ARM64-only (arm64-v8a) configuration
- Landscape-first editor orientation
- Touch event forwarding
- CMake native build integration

The next steps will build the editor systems on top of this original engine core.