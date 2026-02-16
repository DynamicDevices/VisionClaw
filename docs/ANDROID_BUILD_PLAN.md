# Android Build Plan – VisionClaw

This document reviews the current iOS setup and outlines **options for creating an Android build** of VisionClaw, with effort, reuse, and trade-offs.

---

## 1. Current iOS Architecture (Summary)

| Layer | iOS implementation | Android equivalent |
|-------|--------------------|--------------------|
| **Glasses / camera** | Meta Wearables DAT (MWDATCore, MWDATCamera) – Swift | [Meta Wearables DAT Android](https://github.com/facebook/meta-wearables-dat-android) – Kotlin |
| **AI / voice** | Gemini Live API over WebSocket | Same API (platform-agnostic) |
| **Agentic actions** | OpenClaw gateway (HTTP + WebSocket) | Same (platform-agnostic) |
| **Optional video call** | WebRTC (PiP, signaling) | WebRTC Android (e.g. webrtc.org) |
| **UI** | SwiftUI | Jetpack Compose (or XML) |
| **Phone camera fallback** | iPhone camera → frames to Gemini | CameraX / Camera2 → frames to Gemini |
| **Settings / QR** | SwiftUI, AVFoundation QR | Compose, ML Kit / ZXing QR |

**Reusable as-is on Android**

- Gemini Live: same WebSocket URL, auth, JSON protocol.
- OpenClaw: same host/port/tokens, same tool-call JSON.
- Server (e.g. `samples/CameraAccess/server`): no change for Android.

**Platform-specific**

- Meta DAT (glasses streaming, registration, permissions): use [meta-wearables-dat-android](https://github.com/facebook/meta-wearables-dat-android) on Android.
- UI, navigation, camera capture, audio: reimplement in Kotlin/Compose (or chosen stack).
- Secrets/config: Android `BuildConfig` / `local.properties` / same env-based approach as CI.

---

## 2. Option A: Native Android (Kotlin + Jetpack Compose) – **Recommended**

**Idea:** Build an Android app that mirrors the iOS structure: same features (glasses + phone camera, Gemini Live, OpenClaw, optional WebRTC), using the official Meta Android DAT and the same backend contracts.

**Pros**

- Direct use of [Meta Wearables DAT Android](https://github.com/facebook/meta-wearables-dat-android) (video, audio, registration, permissions), aligned with current iOS DAT usage.
- Same Gemini Live and OpenClaw integration (copy protocol and message shapes; reimplement only transport and threading in Kotlin).
- No cross-platform framework lock-in; each platform can follow its own best practices and SDKs.
- Fits existing CI style: add an `android-build.yml` (Gradle, APK/AAB), similar to `ios-build.yml`.
- Clear path for “Android phone mode” (CameraX → send frames to Gemini) analogous to iPhone mode.

**Cons**

- Full reimplementation of UI and app flow in Kotlin/Compose (no code reuse from Swift).
- Two codebases to maintain (iOS + Android); shared logic only in docs, API contracts, and server.

**Effort (rough)**

- **Core path (glasses + Gemini + OpenClaw):** ~3–6 weeks for one experienced Android dev (registration, streaming, Gemini WebSocket client, OpenClaw HTTP/WS, settings, QR).
- **Phone camera mode + polish:** +1–2 weeks.
- **WebRTC (if desired):** +1–2 weeks (signaling already exists; integrate webrtc.org on Android).

**Reuse**

- 100% of “backend” design: Gemini Live protocol, OpenClaw tool-call format, server.
- 0% of UI/native code (by design).

---

## 3. Option B: Flutter (Dart)

**Idea:** One Flutter app for iOS and Android; use platform channels to call the native Meta DAT on each side (iOS Swift, Android Kotlin).

**Pros**

- Single UI codebase (Dart/Widgets).
- Shared business logic in Dart (Gemini client, OpenClaw client, config, tool parsing).
- One repo, one test suite for shared logic.

**Cons**

- Meta DAT is **native-only** (Swift + Kotlin). You must:
  - Maintain Flutter plugin(s) that wrap [meta-wearables-dat-ios](https://github.com/facebook/meta-wearables-dat-ios) and [meta-wearables-dat-android](https://github.com/facebook/meta-wearables-dat-android), or depend on a community one if it exists and is kept up to date.
- Current iOS app is deeply Swift/SwiftUI; porting to Flutter is a full rewrite of the existing app, not an “add Android” step.
- Debugging spans Dart + native (iOS/Android); CI needs both Xcode and Gradle.

**Effort**

- **Larger than Option A for “first Android-capable version”:** Flutter app from scratch + two native DAT plugins (or one dual-platform plugin) + Gemini/OpenClaw in Dart. Estimate ~2–3 months for parity with current iOS, then Android “for free” from the same app.

**Reuse**

- After rewrite: UI and app logic shared; only DAT and possibly camera/audio are native behind channels.

---

## 4. Option C: Kotlin Multiplatform (KMP)

**Idea:** Shared Kotlin code for Gemini Live client, OpenClaw client, and domain models; native UI on both platforms (SwiftUI on iOS, Compose on Android). Android consumes the shared module directly; iOS consumes it via a KMP framework (e.g. Kotlin/Native output).

**Pros**

- Real code reuse: WebSocket handling, JSON parsing, tool-call routing, config validation in one place.
- iOS keeps SwiftUI; Android uses Compose; only “brain” is shared.

**Cons**

- iOS integration is non-trivial: Kotlin/Native, CocoaPods/SPM wrapper, and ensuring the Gemini/OpenClaw client runs correctly from Swift (threading, callbacks).
- Current iOS codebase is 100% Swift; introducing KMP means a new build system and dependency story on both sides.
- Overkill if the shared logic is “just” a few hundred lines of protocol and HTTP/WS glue.

**Effort**

- **Higher than Option A** for getting to a shippable Android app: KMP setup, shared module design, iOS consumption layer, then the Android app. Often 2–4 weeks extra before Android catches up to “Option A starting point.”

**Reuse**

- High for network/domain layer; UI remains native on both.

---

## 5. Option D: React Native

**Idea:** JavaScript/TypeScript app with native modules for Meta DAT (iOS + Android) and for camera; Gemini and OpenClaw called from JS (fetch/WebSocket).

**Pros**

- One JS codebase for UI and API calls.
- Large ecosystem and hiring pool.

**Cons**

- Same as Flutter: Meta DAT is native-only; you need (or must build) RN native modules for both platforms.
- Current app is Swift/SwiftUI; full rewrite to React Native.
- Debugging and performance tuning across JS bridge and native; CI and release pipeline more involved.

**Effort**

- Similar in spirit to Flutter: full rewrite, then one codebase for both platforms. Typically ~2–3 months for feature parity.

**Reuse**

- After rewrite: UI and non-DAT logic in JS; DAT and possibly camera/audio in native modules.

---

## 6. CI/CD for Android (applies to any option)

Once you have an Android app (Option A recommended):

- **Workflow:** Add `.github/workflows/android-build.yml`:
  - Checkout, set up JDK (e.g. 17 or 21), run Gradle (assembleRelease or bundleRelease).
  - Optional: run static analysis (e.g. ktlint/Detekt) and fail on violations to keep “zero warnings” policy.
  - Produce **AAB** (Play Store) and/or **APK** (sideload/Testing), upload as artifacts (e.g. retention 30 days, mirroring iOS).
- **Secrets:** Use GitHub secrets for signing (keystore, passwords) and inject into Gradle (e.g. `local.properties` or env); do not commit keystores.
- **Runner:** `runs-on: ubuntu-latest` is enough for Gradle; no macOS required for the Android build itself.

This mirrors the structure of `ios-build.yml` (lint → build → artifact) and keeps both platforms consistent.

---

## 7. Recommendation Summary

| Option | Best for | First Android build | Long-term |
|--------|----------|----------------------|-----------|
| **A – Native Android (Kotlin + Compose)** | Fastest path to a real Android app, minimal risk, reuse of design only | **Recommended** | Two codebases; clear and maintainable |
| **B – Flutter** | Single UI codebase and willingness to rewrite iOS | Rewrite then both platforms | One app, two native DAT integrations |
| **C – KMP** | Strong need to share protocol/domain code and keep native UI | After KMP + iOS integration | Shared “brain”, native UI both sides |
| **D – React Native** | Strong JS/React preference and willingness to rewrite | Rewrite then both platforms | One app, native DAT modules |

**Practical path:** Start with **Option A**. Implement an Android app in Kotlin + Compose that:

1. Uses Meta Wearables DAT Android for glasses streaming and registration.
2. Reuses the same Gemini Live WebSocket protocol and OpenClaw tool-call format (reimplement in Kotlin).
3. Adds “phone mode” with CameraX feeding frames into the same Gemini pipeline.
4. Adds `android-build.yml` for build and artifacts.

Then, if you later want more code reuse, you can extract a small shared module (e.g. protocol constants, JSON shapes) into a KMP library or a separate repo consumed by both apps—without committing to a full KMP or Flutter rewrite up front.

---

## 8. References

- [Meta Wearables DAT Android](https://github.com/facebook/meta-wearables-dat-android) – Ray-Ban glasses on Android.
- [Meta Wearables Developer – Android](https://wearables.developer.meta.com/docs/build-integration-android/) – Integration and permissions.
- [Gemini Live API](https://ai.google.dev/gemini-api/docs/live) – Same for iOS and Android.
- [OpenClaw](https://github.com/nichochar/openclaw) – Gateway and tool protocol (platform-agnostic).
- Current iOS CI: `.github/workflows/ios-build.yml` – pattern for lint, build, artifact, and “zero warnings”.
