# RC Mobile Studio — implementation requirements

Derived from the supplied Unity Mobile / RC Empire master prompt.

## P0 — mobile foundation
- Android ARM64 launch
- Mobile-first UI
- Touch: tap, double tap, long press, drag, swipe, pinch, two-finger pan/rotate, multitouch
- Touch scene navigation, selection and transform controls
- Project open/save
- Basic scene editing
- Play/test mode

## P1 — core editor
- Hierarchy
- Inspector
- Project/assets
- Components and resources
- Prefabs
- Materials
- Animation
- Audio
- Physics
- UI editing
- Script editing
- Console

## P2 — mobile optimization
- Rendering and memory optimization
- Quality presets
- Profiling
- LOD
- Asset optimization
- Scene streaming where supported

## P3 — Android build
- ARM64 builds
- Debug/development/release configuration where supported
- App name, package, version, icon, splash and orientation settings
- Clear SDK/NDK/JDK/build diagnostics

## P4 — online
- Authorized service integrations only
- No fake Unity servers
- No hard-coded secrets
- No hidden telemetry
- No silent project uploads
- Multiplayer remains optional

## UX
- Dark theme first; optional light theme
- Bottom toolbars/sheets and drawers
- Large touch targets
- Search/context menus
- Safe-area handling
- Phone and tablet portrait/landscape
- Accessibility scaling and left/right-handed layouts

## Engineering rules
1. Inspect before changing.
2. Implement incrementally.
3. Build after every major milestone.
4. Test Android ARM64.
5. Fix errors before moving on.
6. Never replace complex systems with fake buttons.
7. Preserve applicable upstream attribution and licensing.
