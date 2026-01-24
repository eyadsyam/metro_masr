# ✅ Master Fix: Google Sign-In & Offline Crash

I have successfully updated your code to handle the errors you were seeing.

## 🛠️ What I Fixed (Code Side)

1.  **Fixed Font Crashes (SocketException)**:
    - I modified `metro_theme.dart` to **stop trying to download fonts** from the internet.
    - The app will now use system fonts instead of crashing with `PlatformException`.
    - Once you are online/ready, we can re-enable beautiful fonts by adding them to `assets/`.

2.  **Fixed Missing Google Services Plugin**:
    - I detected that `com.google.gms.google-services` was missing from your Gradle build files.
    - I added it to `android/settings.gradle.kts` and `android/app/build.gradle.kts`.

3.  **Improved Error Handling**:
    - The app now catches "Network Error" (Code 7) and shows a friendly message instead of crashing.

---

## 🚨 Final Step Required From You (Cannot be skipped)

For Google Sign-In to work on Android, you **MUST** do this:

1.  **Download `google-services.json`**:
    - Go to [Firebase Console](https://console.firebase.google.com/) -> Your Project -> Project Settings.
    - Download the file `google-services.json`.
    - **Move it to**: `d:\Flutter Data\Projects\metro_guide_app\metro_masr\android\app\google-services.json`.

2.  **Verify SHA-1 Fingerprint**:
    - Ensure your debug SHA-1 key is added to the Firebase/Google Cloud Console (as detailed in `SHA1_GUIDE.md`).

### 🚀 How to Run Now

1.  Clean the build:
    ```bash
    flutter clean
    flutter pub get
    ```
2.  Run the app:
    ```bash
    flutter run
    ```

**The app should now launch without crashing.** If you add the JSON file, Google Sign-In will work too.
