# MTA Mobile

An enterprise collaboration platform built with Flutter, featuring real-time chat, project management, meetings, attendance tracking, and document management.

## Version History

| | Flutter | Dart | Kotlin | AGP |
|---|---|---|---|---|
| **Old** | 3.16.0 | 3.2.0 | — | — |
| **Previous** | 3.19.2 | 3.3.0 | — | — |
| **Current** | 3.41.4 | 3.11.1 | 2.0.21 | 8.11.1 |

**App Version:** 1.0.0 (UAT)  
**Min Android SDK:** 21 &nbsp;|&nbsp; **Target SDK:** 36

---

## Features

- **Authentication** — Login, OTP verification, PIN setup
- **Projects & Dashboard** — Project listing, team dashboards, categories
- **Real-time Chat** — Group messaging, voice messages, media sharing, @mentions, reactions, link previews
- **Meetings** — Create/edit/delete meetings, location selection via Google Maps, meeting history
- **Attendance** — Mark and track attendance
- **Documents** — Upload, view, comment, and download documents (PDF support)
- **Notifications** — Firebase push notifications
- **Profile** — User profile management

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.41.4 |
| Language | Dart 3.11.1 |
| State Management | Provider |
| Networking | Retrofit + Dio |
| Real-time | Socket.IO |
| Push Notifications | Firebase Messaging |
| Maps | Google Maps Flutter |
| Media | image_picker, audio_waveforms, flutter_pdfview |

---

## Requirements

- Flutter 3.41.4+
- Dart 3.11.1+
- Java 17
- Android Studio / VS Code with Flutter extension

---

## Setup

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run
```

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ipa --release
```

---

## Environment

- **UAT API:** `https://uatmta.multitechcorp.in/mta/`
- **Socket:** `https://uatmta.multitechcorp.in:5022/`
