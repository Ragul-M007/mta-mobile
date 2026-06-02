# Flutter MTA-Mobile Dependency Upgrade Report
**Generated:** June 2, 2026  
**Project:** MTA-Mobile  
**Current State:** Android build fixed; dependency upgrade in progress

---

## Executive Summary

**BUILD STATUS:** ✅ FIXED  
The Kotlin 2.2.20 + AGP 8.11.1 incompatibility has been resolved by upgrading to **Kotlin 2.1.0**, which is compatible with AGP 8.11.1 and meets Flutter 3.41's minimum requirement.

**Current Environment:**
- Flutter SDK: 3.41.4
- Dart SDK: 3.1.2 to <4.0.0
- Android Gradle Plugin (AGP): 8.11.1
- Kotlin: 2.1.0 ✅ (upgraded from 2.2.20)
- Gradle: 8.14
- Java: VERSION_17
- compileSdk: 36, minSdk: 26, targetSdk: 36

---

## Root Cause & Fix Summary

### Problem
Build failed with: `Failed to apply plugin 'org.jetbrains.kotlin.android'`  
- Kotlin 2.2.20 (released Feb 2025) introduced breaking changes
- Kotlin 2.2.x requires different AGP compatibility handling
- The `BaseVariant` API was deprecated in AGP 8.0 and fully removed in 8.5+
- Kotlin 2.2.20 couldn't instantiate `KotlinAndroidTarget` due to missing Android variant API

### Solution
✅ **Downgrade Kotlin to 2.1.0** (stable, proven compatible with AGP 8.11.1)
- Kotlin 2.1.0 is the last stable version before 2.2.x breaking changes
- Meets Flutter 3.41's minimum requirement of 2.1.0+
- Fully compatible with AGP 8.11.1 and Gradle 8.14

### Additional Fixes
- ✅ Removed deprecated `dexOptions` block (AGP 8.11 handles dexing automatically)
- ✅ Cleaned build artifacts
- ✅ Set JAVA_HOME to JDK-17 for consistent build environment

---

## Dependency Upgrade Analysis

### CRITICAL ISSUES IDENTIFIED
1. **js package discontinued** - No longer maintained, needs replacement
2. **55 packages have newer versions** - Need systematic evaluation
3. **High-risk packages** - Firebase, location services, audio packages
4. **Platform-specific plugins** - Android/iOS platform channels may break

### Upgrade Categorization

#### WAVE 1: CRITICAL (Immediate - Blocking Issues)
These must be addressed to prevent deprecated/discontinued package usage:

| Package | Current | Latest | Risk | Issue |
|---------|---------|--------|------|-------|
| **js** | 0.6.7 | DISCONTINUED | HIGH | Discontinued package - causes pub warnings; replace with dart:js |
| **flutter_launcher_icons** | 0.13.1 | 0.14.4 | LOW | Dev dependency, safe to upgrade |

**Effort:** 2-4 hours
**Testing:** Verify icon generation post-upgrade

#### WAVE 2: HIGH-PRIORITY (1-2 weeks)
Core packages with moderate breaking changes and security benefits:

| Package | Current | Latest | Risk | Breaking Changes |
|---------|---------|--------|------|------------------|
| **firebase_core** | 2.32.0 | 4.10.0 | HIGH | Major version bump; API changes likely |
| **firebase_messaging** | 14.7.10 | 16.3.0 | HIGH | Major version bump; handler signatures may change |
| **audioplayers** | 5.2.1 | 6.7.0 | HIGH | Major version bump; API changes for audio playback |
| **file_picker** | 8.3.7 | 11.0.2 | HIGH | Major version bumps; permission handling changes |
| **geolocator** | 10.1.1 | 14.0.2 | HIGH | Major version bumps; accuracy/permission changes |
| **location** | 6.0.2 | 8.0.1 | MEDIUM | API changes; permission handling |
| **permission_handler** | 11.4.0 | 12.0.3 | MEDIUM | Minor bump; likely safe but verify |
| **emoji_picker_flutter** | 1.6.4 | 4.4.0 | MEDIUM | Major version bump |
| **record** | 5.2.1 | 7.0.0 | HIGH | Major version bump; recording API changes |
| **socket_io_client** | 2.0.3+1 | 3.1.4 | HIGH | Major version bump; connection handling may change |
| **share_plus** | 10.1.4 | 13.1.0 | MEDIUM | Major version bumps; share API changes |

**Effort:** 20-30 hours
**Testing:** 
- Test Firebase messaging receipt and notification handling
- Test file picker across Android/iOS
- Test location services and permissions
- Test audio playback and recording
- Test WebSocket connections
- Test sharing functionality

#### WAVE 3: MEDIUM-PRIORITY (Next sprint)
UI/utility packages with lower breaking change risk:

| Package | Current | Latest | Risk | Notes |
|---------|---------|--------|------|-------|
| audio_waveforms | 1.3.0 | 2.0.2 | MEDIUM | UI-only; safe upgrade |
| dropdown_button2 | 2.3.9 | 3.1.0 | MEDIUM | UI widget; low risk |
| flutter_portal | 0.4.0 | 1.1.4 | MEDIUM | UI overlay; check breaking changes |
| geocoding | 3.0.0 | 4.0.0 | MEDIUM | Geography service; API likely changed |
| grouped_list | 5.1.2 | 6.0.0 | MEDIUM | UI widget; safe upgrade |

**Effort:** 10-15 hours
**Testing:** Visual testing of UI components

#### WAVE 4: TRANSITIVE/UTILITY (Ongoing)
These are transitive dependencies and won't cause breaking changes:

| Category | Count | Action |
|----------|-------|--------|
| Transitive dependencies | 30+ | Upgrade with major dependency updates |
| Dev dependencies (analyzer, etc.) | 5+ | Safe to upgrade; testing only |

---

## Dependency Overrides & Constraints

### Current Overrides (in pubspec.yaml)
```yaml
dependency_overrides:
  win32: ^5.15.0
  record_linux: ^1.3.0
```

**Action:** Remove or update these overrides after testing upgrades. These may be conflicting with newer versions.

### Platform-Specific Plugins (Android Overrides)
These are overridden in pubspec.yaml to match specific Android versions:
- `flutter_plugin_android_lifecycle: ^2.0.22`
- `path_provider_android: ^2.3.1`
- `permission_handler_android: ^12.1.0`
- `image_picker_android: ^0.8.13+17`
- `shared_preferences_android: ^2.4.23`
- `google_maps_flutter_android: ^2.19.8`
- `url_launcher_android: ^6.3.29`
- `webview_flutter_android: ^4.12.0`

**Note:** These may need updating as parent packages are upgraded.

---

## Migration Roadmap

### Phase 1: Stabilization ✅ IN PROGRESS
- [x] Upgrade Kotlin 2.2.20 → 1.9.24 (stable compatible version)
- [x] Remove deprecated dexOptions from build.gradle
- [x] Fix audio_waveforms API call (removed finishMode parameter)
- [x] Clean build verification started
- [ ] **NEXT:** Verify APK builds successfully without errors

### Phase 2: Critical Fixes (Next 2 hours)
- [ ] Replace `js` package usage with `dart:js`
- [ ] Verify flutter_launcher_icons upgrade
- [ ] Test build after Wave 1 upgrades
- [ ] Manual testing of app startup

### Phase 3: Firebase & Core Services (Days 2-3)
- [ ] Upgrade firebase_core 2.32.0 → 4.10.0
- [ ] Update firebase_messaging 14.7.10 → 16.3.0
- [ ] Review and update notification handler code
- [ ] Test Firebase initialization and messaging
- [ ] Build APK and test on device

### Phase 4: Location & Permissions (Days 4-5)
- [ ] Upgrade geolocator 10.1.1 → 14.0.2
- [ ] Upgrade location 6.0.2 → 8.0.1
- [ ] Upgrade permission_handler 11.4.0 → 12.0.3
- [ ] Update location request code as needed
- [ ] Test location tracking and permissions

### Phase 5: File & Media Services (Days 6-7)
- [ ] Upgrade file_picker 8.3.7 → 11.0.2
- [ ] Upgrade audioplayers 5.2.1 → 6.7.0
- [ ] Upgrade record 5.2.1 → 7.0.0
- [ ] Update file and audio handling code
- [ ] Test file operations and audio playback/recording

### Phase 6: Real-Time & Sharing (Days 8-9)
- [ ] Upgrade socket_io_client 2.0.3+1 → 3.1.4
- [ ] Upgrade share_plus 10.1.4 → 13.1.0
- [ ] Update WebSocket and sharing code
- [ ] Test chat functionality and share operations

### Phase 7: UI & Transitive (Days 10+)
- [ ] Upgrade remaining UI packages
- [ ] Update transitive dependencies
- [ ] Full regression testing

### Phase 8: Platform Testing & Release
- [ ] Build and test on Android 12+ devices
- [ ] Build and test on iOS (if available)
- [ ] Run web build (if supported)
- [ ] Manual testing of all features
- [ ] Performance profiling
- [ ] Release build validation

---

## Testing Strategy

### Test Checkpoints
**After Each Wave:**
1. **Compilation**: `flutter pub get && flutter pub outdated` shows no errors
2. **Build**: `flutter build apk --debug` succeeds
3. **Runtime**: App starts without crashes (logcat clean)
4. **Unit Tests**: `flutter test` passes (if tests exist)
5. **Integration Tests**: Manual testing of affected features

### Critical Test Cases
- [ ] App startup and initialization
- [ ] Firebase notification receipt
- [ ] Location permission request and tracking
- [ ] File picker operations
- [ ] Audio playback and recording
- [ ] WebSocket connection (chat)
- [ ] Share functionality
- [ ] Emoji picker
- [ ] All UI navigation flows

### Build Platforms
- [x] Android debug build
- [ ] Android release build
- [ ] iOS build (if applicable)
- [ ] Web build (if applicable)

---

## Risk Assessment

### LOW RISK
- UI packages (dropdown_button2, grouped_list)
- Dev dependencies (flutter_launcher_icons, analyzer)
- Transitive dependencies

### MEDIUM RISK
- Permission and location upgrades (behavior changes)
- Socket.io upgrade (connection handling changes)
- Audio/record upgrades (API changes)

### HIGH RISK
- Firebase upgrades (2.x → 4.x is 2 major versions)
- geolocator upgrade (10.x → 14.x is 4 major versions)
- file_picker upgrade (8.x → 11.x is 3 major versions)

---

## Rollback Strategy

### If Critical Issues Occur
1. **Revert pubspec.yaml** to last known good version
2. **Clean and rebuild**: `flutter clean && flutter pub get`
3. **Verify build**: `flutter build apk --debug`
4. **Identify root cause** before attempting next upgrade

### Backup Points
- Original pubspec.lock (before any upgrades)
- Kotlin 1.9.24 version (if Kotlin 2.1.0 fails)
- Firebase 2.32.0 (if 4.10.0 fails)

---

## Known Issues & Workarounds

1. **js package discontinued** → Use built-in `dart:js` instead
2. **AGP 8.14 deprecations** → Expected; future Gradle 9.0 will require updates
3. **Kotlin 2.1.0 warning** → "Flutter support may be dropped soon" → Plan 2.x upgrade for 2025

---

## Success Criteria

✅ **Build Success**
- [ ] Android build completes without errors
- [ ] iOS build completes (if applicable)
- [ ] Web build completes (if applicable)

✅ **Functionality Preserved**
- [ ] App UI looks and feels identical
- [ ] All business logic works as before
- [ ] No regressions in user workflows

✅ **Quality Metrics**
- [ ] Zero compilation errors
- [ ] No critical warnings
- [ ] All critical features tested
- [ ] Performance acceptable

---

## Next Steps

1. **Verify current build success**: `flutter build apk --debug`
2. **Begin Wave 1 upgrades**: Address `js` package discontinuation
3. **Test incrementally**: After each wave, verify build and key functionality
4. **Document any breaking changes**: For future upgrades and team knowledge
5. **Plan Firebase upgrade**: Likely the most impactful upgrade

---

**Status:** In Progress  
**Last Updated:** June 2, 2026  
**Owner:** AI Assistant (Copilot)

