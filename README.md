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

## Step 3 — Mobile UI/Layout System
- Responsive viewport-aware UI node layout
- Anchors for top-left, top-right, bottom-left, bottom-right and center
- Touch hit-testing and enabled/visible UI state
- Native engine UI event routing

## Step 4 — Touch + Multitouch Input
- Pointer IDs tracked independently
- Touch down/move/up/cancel forwarding from Android
- Two-finger pan delta
- Pinch distance and zoom delta
- Two-finger rotation delta


## Step 5 — 3D Renderer Foundation
- Original GLES3 renderer abstraction
- Depth testing and frame lifecycle
- Viewport resize handling
- Clear-frame and renderer state foundation

## Step 6 — Camera + Viewport Controls
- Orbit camera with pitch limits
- Pan and zoom controls
- Focus target support
- Editor viewport controller
- Mobile-ready drag/pinch control hooks


## Step 7 — GameObject / Entity System
- Stable entity IDs
- Entity names and active state
- Transform data
- Scene create/destroy/find operations

## Step 8 — Hierarchy + Parent/Child
- Parent/child relationships
- Child lists
- Reparenting
- Cycle protection
- Recursive hierarchy destruction
- Inspector transform editing API
