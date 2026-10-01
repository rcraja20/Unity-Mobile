# RC Mobile Studio

RC Empire — Mobile Game Development Studio

This is a mobile-first game-development workspace built around an open-source engine foundation. It does not contain proprietary Unity source code.

## Goals
- Android ARM64 first
- Touch-first 2D/3D editor UX
- Project and scene management
- Hierarchy and Inspector
- Assets, scripts, animation, audio and physics workflows
- Play/test workflow
- Android build/export
- Console and diagnostics
- Responsive phone/tablet layouts
- RC Empire branding
- Offline-first local project storage

See PRODUCT_REQUIREMENTS.md and UPSTREAM.md.

## Current implementation status
The repository now contains an integrated mobile editor foundation covering local projects, scene/hierarchy/inspector workflows, assets, scripts, diagnostics, mobile quality profiling, Android ARM64 build configuration, privacy controls, accessibility settings, touch/game-control foundations, and local scene serialization.

### Important scope note
This repository uses Godot as an open-source foundation. It is not a redistribution of Unity source and does not claim Unity licensing, Unity package compatibility, or Unity service compatibility. A genuine Unity-source adaptation requires the authorized Unity source distribution and applicable permissions.

The Android workflow is a CI build pipeline; an APK/editor artifact is only considered verified after a successful GitHub Actions run produces the artifact.
## Current milestone
The repository currently contains the mobile editor foundation and a CI Android ARM64 editor build workflow. Feature-complete status is intentionally not claimed until the implementation is built and tested successfully.
