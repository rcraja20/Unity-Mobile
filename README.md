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


## Step 9 — Inspector + Transform
- Entity rename, active state, position, rotation and scale editing.
- Component creation is exposed through the Inspector API.

## Step 10 — Components System
- Component base interface and per-entity storage.
- MeshRenderer, Camera and Light components.
- Component enable state and cleanup on entity deletion.

## Steps 16–20
- **16:** Game UI widget/editor model.
- **17:** Script asset + runtime foundation.
- **18:** Play/pause/resume game session.
- **19:** Android ARM64 build settings and validation pipeline.
- **20:** Frame profiler statistics and final runtime integration.

These modules are foundations, not a claim of a production-complete editor/build toolchain; platform-specific rendering, compilers, Android packaging and full UI remain implementation work.


## Steps 21–25 — Production Path Foundations
- **21:** Mesh and texture data models for the renderer.
- **22:** Asset importer API with common model/texture/audio/animation detection.
- **23:** Collision-world interface added alongside physics.
- **24:** Editor selection foundation and editor-side state hooks.
- **25:** Transform gizmo state and Move/Rotate/Scale modes.

These are implementation foundations; actual GPU rendering, file decoding, collision resolution and full touch-driven editor UI still require further work and device testing.


## Steps 26–30 — Final Production Foundations
- **26:** Script compiler/diagnostic interface.
- **27:** Runtime start/stop/pause/resume state.
- **28:** Android ARM64 build validation.
- **29:** Diagnostics and error tracking foundation.
- **30:** Final Android package manifest foundation.

The roadmap is structurally complete, but a production-ready release still requires actual implementation/testing of GPU rendering, import decoding, collision resolution, scripting backend, Android APK packaging, UI integration and physical-device validation.
