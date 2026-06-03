# Flutter MTA-Mobile: Comprehensive Modernization Plan

**Date:** June 2, 2026  
**Status:** Upgrade Planning Phase  
**Flutter Version:** 3.41.4 (Latest Stable)  
**Dart Version:** 3.11.1 (Latest Stable)

---

## PHASE OVERVIEW

| Phase | Focus | Risk | Effort | Est. Time |
|-------|-------|------|--------|-----------|
| Phase 1 | Kotlin + AGP + Gradle modernization | LOW | 2h | ✅ DONE |
| Phase 2 | Discontinued packages + critical fixes | MEDIUM | 2h | 1-2h |
| Phase 3 | Firebase modernization | HIGH | 8h | 2-3 days |
| Phase 4 | Location & permission services | HIGH | 6h | 1-2 days |
| Phase 5 | Audio/media & networking | MEDIUM | 8h | 1-2 days |
| Phase 6 | UI & utility packages | LOW | 4h | 1 day |
| Phase 7 | Final testing & verification | MEDIUM | 4h | 1 day |

---

## DETAILED UPGRADE MATRIX

### PHASE 2: CRITICAL FIXES & DISCONTINUED PACKAGES

| Package | Current | Latest | Major Changes | Priority | Action |
|---------|---------|--------|---|----------|--------|
| js | 0.6.7 | DISCONTINUED | Dart now has built-in `dart:js` | CRITICAL | Remove & migrate to dart:js |
| audio_waveforms | 1.0.4 | 2.0.2 | Major API overhaul | HIGH | Fix voice message playback |
| flutter_launcher_icons | 0.13.1 | 0.14.4 | Minor API cleanup | LOW | Safe upgrade |
| cupertino_icons | 1.0.9 | 1.0.10 | Patch update | LOW | Safe upgrade |
| provider | 6.1.5+1 | 6.4.1 | Bug fixes only | LOW | Safe upgrade |
| logging | 1.3.0 | 1.3.1 | Patch update | LOW | Safe upgrade |
| pretty_dio_logger | 1.4.0 | 1.4.1 | Patch update | LOW | Safe upgrade |
| http | 1.6.0 | 1.6.4 | Patch update | LOW | Safe upgrade |
| intl | 0.20.2 | 0.20.3 | Patch update | LOW | Safe upgrade |
| timeago | 3.7.1 | 3.7.2 | Patch update | LOW | Safe upgrade |
| uuid | 4.5.3 | 4.8.0 | New features, compatible | LOW | Safe upgrade |

### PHASE 3: FIREBASE MODERNIZATION

| Package | Current | Latest | Breaking Changes | Migration Path |
|---------|---------|--------|---|---|
| firebase_core | 2.32.0 | 4.10.0 | Major version jump (2 versions) | Update initialization code |
| firebase_messaging | 14.7.10 | 16.3.0 | Notification handler changes | Update message handlers |
| _flutterfire_internals | 1.3.35 | 1.3.72 | Internal API changes | Auto-resolved |

**Risk:** HIGH - Firebase 4.x has significant changes  
**Testing:** Notification receipt, FCM token handling, message parsing

### PHASE 4: LOCATION & PERMISSIONS

| Package | Current | Latest | Breaking Changes | Migration Path |
|---------|---------|--------|---|---|
| geolocator | 10.1.1 | 14.0.2 | Major rewrite (4 versions) | Accuracy settings, permission model |
| location | 6.0.2 | 8.0.1 | API restructure (2 versions) | Location request syntax |
| permission_handler | 11.4.0 | 12.0.3 | Permission model update (1 version) | Minor API changes |
| geocoding | 3.0.0 | 4.0.0 | Major version bump (1 version) | Safe upgrade |

**Risk:** HIGH - Location services are critical  
**Testing:** Permission requests, location accuracy, permission denied handling

### PHASE 5: AUDIO, NETWORKING & MEDIA

| Package | Current | Latest | Breaking Changes | Migration Path |
|---------|---------|--------|---|---|
| audioplayers | 5.2.1 | 6.7.0 | Major API overhaul (1 version) | Playback control changes |
| record | 5.2.1 | 7.0.0 | Recording API changes (2 versions) | Recording start/stop methods |
| socket_io_client | 2.0.3+1 | 3.1.4 | WebSocket connection handling (1 version) | Event emission changes |
| file_picker | 8.3.7 | 11.0.2 | Permission handling (3 versions) | File type filtering |
| flutter_downloader | 1.12.0 | 1.14.0 | Task ID changes (0 major) | Safe upgrade |
| flutter_web_browser | 0.17.3 | 0.18.0 | Minor changes | Safe upgrade |
| share_plus | 10.1.4 | 13.1.0 | Major API overhaul (3 versions) | Share method changes |

**Risk:** MEDIUM-HIGH - Audio and networking are feature-critical  
**Testing:** Voice message playback/recording, WebSocket chat, file downloads, share functionality

### PHASE 6: UI & UTILITIES

| Package | Current | Latest | Breaking Changes | Migration Path |
|---------|---------|--------|---|---|
| dropdown_button2 | 2.3.9 | 3.1.0 | Widget properties (1 version) | Safe upgrade |
| emoji_picker_flutter | 1.6.4 | 4.4.0 | Major UI overhaul (3 versions) | UI props changes |
| grouped_list | 5.1.2 | 6.0.0 | ListView builder changes (1 version) | Safe upgrade |
| flutter_portal | 0.4.0 | 1.1.4 | Positioning API (0 major) | Safe upgrade |
| table_calendar | 3.2.0 | 3.2.0 | Up-to-date | No action |
| connectivity_plus | 7.1.1 | 7.1.2 | Patch update | Safe upgrade |
| flutter_easyloading | 3.0.5 | 3.0.5 | Up-to-date | No action |
| fluttertoast | 9.0.0 | 9.1.0 | Patch update | Safe upgrade |
| auto_size_text | 3.0.0 | 3.0.0 | Up-to-date | No action |
| chat_bubbles | 1.5.0 | 1.5.0 | Up-to-date | No action |
| cached_network_image | 3.4.1 | 3.4.1 | Up-to-date | No action |
| flutter_parsed_text | 2.2.1 | 2.2.1 | Up-to-date | No action |
| flutter_linkify | 6.0.0 | 6.0.0 | Up-to-date | No action |
| html | 0.15.6 | 0.15.6 | Up-to-date | No action |
| any_link_preview | 3.0.3 | 3.0.3 | Up-to-date | No action |
| sms_autofill | 2.4.1 | 2.4.1 | Up-to-date | No action |
| multi_select_flutter | 4.1.3 | 4.1.3 | Up-to-date | No action |
| retrofit | 4.4.2 | 4.7.0 | Generator updates | Safe upgrade |
| json_annotation | 4.9.0 | 4.8.0 | DOWNGRADE needed | Compatible version |
| dio | 5.9.2 | 5.12.0 | Patch updates | Safe upgrade |
| webview_flutter | 4.13.1 | 4.13.1 | Up-to-date | No action |
| path_provider | 2.1.5 | 2.1.5 | Up-to-date | No action |
| image_picker | 1.2.2 | 1.2.2 | Up-to-date | No action |
| scrollable_positioned_list | 0.3.8 | 0.3.8 | Up-to-date | No action |
| google_maps_flutter | 2.6.1 | 2.8.0 | Marker changes (0 major) | Safe upgrade |
| google_places_flutter | 2.0.9 | 2.0.9 | Up-to-date | No action |
| flutter_image_compress | 2.4.0 | 2.4.0 | Up-to-date | No action |
| open_filex | 4.7.0 | 4.7.0 | Up-to-date | No action |
| url_launcher | 6.3.2 | 6.3.2 | Up-to-date | No action |

**Risk:** LOW - These are UI elements and utilities  
**Testing:** Visual regression testing only

---

## RECOMMENDED KOTLIN & AGP STRATEGY

### Current State
- Kotlin: 1.9.24 (Stable, but deprecated)
- AGP: 8.11.1 (Latest)
- Gradle: 8.14 (Latest)

### Modernization Path

**Option A: Conservative (Current Plan)**
- Keep Kotlin 1.9.24 until Q4 2026
- Reason: Plugins still compiled with older Kotlin
- Risk: LOW

**Option B: Aggressive (Advanced)**
- Upgrade to Kotlin 2.0.21 (latest stable 2.0.x)
- Requires all plugins to be updated first
- Risk: HIGH (breaks current plugins)

**Recommendation:** Stay with Option A for now. Plan Kotlin 2.0 migration after Phase 5 completes.

---

## BUILD & GRADLE UPDATES

### Current Gradle Configuration
- Gradle: 8.14 ✅ Latest
- AGP: 8.11.1 ✅ Latest
- Java: VERSION_17 ✅ Compatible

### No Gradle Changes Needed
Gradle and AGP are already at latest compatible versions.

---

## EXECUTION PLAN

### Phase 2: Start Today
1. Create backup of pubspec.yaml
2. Upgrade non-critical packages (low risk)
3. Handle js discontinuation
4. Upgrade audio_waveforms carefully
5. Test build
6. Verify functionality

### Phase 3-6: Follow-Up
Execute one phase per day with thorough testing between each phase.

### Phase 7: Final Testing
- Full regression testing
- Performance profiling
- Release build generation

---

## DEPENDENCIES TO REMOVE

| Package | Reason | Replacement |
|---------|--------|------------|
| js | Discontinued by Dart team | Use built-in `dart:js` |

---

## SUCCESS CRITERIA

After each phase:
1. ✅ `flutter pub get` succeeds
2. ✅ `flutter analyze` shows no errors
3. ✅ `flutter build apk --debug` succeeds
4. ✅ App launches without crashes
5. ✅ No UI changes visible
6. ✅ Core functionality works

---

## NEXT IMMEDIATE ACTIONS

1. Back up current pubspec.yaml
2. Create Phase 2 upgrade branch
3. Upgrade phase 2 packages incrementally
4. Test each major package upgrade
5. Document all code changes
6. Commit changes
7. Proceed to Phase 3

---

**Ready to proceed with Phase 2?** [YES/NO]

