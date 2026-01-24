---
description: Build and release the Android application
---

This workflow prepares the app assets and builds the release versions for Android.

1.  **Generate App Icons**:
    ```bash
    dart run flutter_launcher_icons
    ```

2.  **Generate Native Splash Screen**:
    ```bash
    dart run flutter_native_splash:create
    ```

3.  **Build Android Bundle (AAB)**:
    *Recommended for Google Play Console.*
    ```bash
    flutter build appbundle --release
    ```

4.  **Build Android APK**:
    *For direct installation on devices.*
    ```bash
    flutter build apk --release
    ```

> **Note for iOS**: Since you are on Windows, you cannot build the iOS app directly. To build for iOS, you must open this project on a Mac and run `flutter build ios` or `flutter build ipa`.
