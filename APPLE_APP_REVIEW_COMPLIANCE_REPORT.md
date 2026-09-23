# Apple App Review Compliance Report — Völtech Premium

This comprehensive audit evaluates the Völtech Premium codebase against Apple’s App Store Review Guidelines following the resolution of Submission `4e4e8ca1-e264-449d-9872-c54c325da328`.

---

## Executive Summary
* **App Name**: Völtech Premium
* **Bundle ID**: `com.voltech.premium`
* **Version / Build**: 1.0.2 (Build 11)
* **Target Platforms**: iOS 15.0+ & iPadOS 15.0+ (Tested on iPad Air 11-inch M3)
* **Primary Technologies**: Flutter / Dart 3.12.2 (Mobile), Java 17 / Spring Boot 3 / PostgreSQL (Backend)
* **Overall Status**: **AUDIT PASSED & COMPLIANCE FIXED** (All identified technical blockers addressed; ready for App Store resubmission).

---

## Guideline 1 — Safety

### 1.1 Objectionable Content
* **Status**: PASS
* **Evidence**: The app is a customer loyalty portal for physical electrical and hardware products. There is no gambling, hate speech, adult content, or harassment.

### 1.2 User-Generated Content
* **Status**: PASS
* **Evidence**: Users can submit service complaints regarding damaged or counterfeit QR codes via `lib/features/scanner/screens/scanner_screen.dart`. Complaints are sent privately to the company admin moderation panel and are not publicly displayed to other users.

### 1.6 Data Security
* **Status**: PASS
* **Evidence**: All backend network traffic uses TLS/HTTPS (`https://voltechpremiumbackend-api-production.up.railway.app/api`). Authentication tokens (`accessToken`, `refreshToken`) are stored in the iOS Keychain via `FlutterSecureStorage`. No sensitive API keys or secrets are exposed in the bundle.

---

## Guideline 2 — Performance

### 2.1 App Completeness
* **Status**: FIXED
* **Evidence**:
  - Removed unused local variables and verified clean code compilation (`flutter analyze`: 0 issues).
  - Production APIs are live with automatic token refresh (`_sendWithRetry`), network connection validation (`connectivity_plus`), and user-friendly error banners.
  - No dummy/mock databases are used in production flows (`DemoDB.users = const []`).
* **Remaining manual checks**: Verify that production Railway backend remains active and responsive throughout the Apple review period.

### 2.3 Accurate Metadata
* **Status**: MANUAL CHECK REQUIRED
* **Evidence**: App name, icons, and bundle configuration in `Info.plist` and `project.pbxproj` match.
* **Remaining manual checks**: Ensure screenshots uploaded to App Store Connect accurately depict the current UI on 6.7" iPhone and 13"/11" iPad.

### 2.5 Software Requirements & iPad Compatibility
* **Status**: FIXED
* **Evidence**:
  - Added `<key>UIRequiresFullScreen</key><true/>` in `ios/Runner/Info.plist` to guarantee stable orientation handling on iPad Air and iPadOS without multitasking window conflicts.
  - Implemented responsive `Center` and `ConstrainedBox` wrappers on `HomeScreen`, `RegisterScreen`, `LoginScreen`, and `ProfileScreen` so layouts do not stretch uncontrollably across 11-inch and 13-inch iPad screens.
  - Executed automated smoke tests (`13/13 tests passed`).

---

## Guideline 3 — Business

### 3.1.1 In-App Purchase
* **Status**: NOT APPLICABLE
* **Evidence**: The app does **not** sell digital content, digital goods, subscriptions, or unlockable features. Points are granted exclusively upon scanning QR codes on physical products purchased off-app. Redeemed gifts are physical items shipped or handed over in person.

### 3.1.2 Subscriptions
* **Status**: NOT APPLICABLE
* **Evidence**: No subscription models or recurring billing mechanisms exist in the application.

---

## Guideline 4 — Design

### 4.2 Minimum Functionality
* **Status**: PASS
* **Evidence**: The application is a fully native Flutter app with custom hardware QR scanning (`mobile_scanner`), interactive animated virtual membership cards, photo gallery avatar uploading, and localized multi-lingual support. It is not a website wrapper or marketing webview.

### 4.8 Login Services
* **Status**: NOT APPLICABLE
* **Evidence**: The app exclusively uses its own first-party account system (SMS OTP phone authentication + password). It does not use third-party social logins (e.g. Google or Facebook); therefore, Sign in with Apple is not required under Guideline 4.8.

---

## Guideline 5 — Legal

### 5.1.1(i) Privacy Policy
* **Status**: PASS
* **Evidence**:
  - In-app Privacy Policy is accessible at any time via `Profile → Privacy Policy` (`PolicyScreen`).
  - Updated `policy_sec2_desc` in Uzbek, Russian, and English to accurately declare that only Name and Phone Number are required, while demographic data (Age, Region, District) is voluntary.
* **Remaining manual checks**: Ensure the public URL configured in App Store Connect points to the identical live privacy statement.

### 5.1.1(ii) Permissions
* **Status**: PASS
* **Evidence**:
  - `NSCameraUsageDescription` clearly explains that camera access is needed solely to scan product QR codes for loyalty points.
  - `NSPhotoLibraryUsageDescription` clearly explains photo library access is only for setting a profile avatar.
  - No extraneous permissions (location, microphone, contacts, Bluetooth, health) are requested.

### 5.1.1(v) Data Minimization (Age, Region, District)
* **Status**: FIXED
* **Evidence**:
  - Backend: In `RegisterDto.java`, removed `@NotNull` and `@NotBlank` from `age`, `region`, and `district`.
  - Frontend: In `register_screen.dart` and `edit_profile_screen.dart`, fields are marked as `(Optional)` / `(Ixtiyoriy)` / `(Необязательно)` and client-side validation no longer enforces them.

### 5.1.1(v) Account Deletion
* **Status**: FIXED
* **Evidence**:
  - In `profile_screen.dart`, added a prominent "Delete Account" button with a red trash icon directly on the main Settings screen, plus a secondary button in `edit_profile_screen.dart`.
  - In `ProfileService.java`, the deletion endpoint permanently erases the user record, clearing related transactions, complaints, and scan logs without foreign key errors.
  - The client wipes all secure Keychain credentials and SharedPreferences and immediately redirects the user to the Login screen.
* **Remaining manual checks**: Capture the required physical-device screen recording demonstrating the account deletion flow following `ACCOUNT_DELETION_TEST_GUIDE.md`.

### 5.1.2 Data Use and Sharing & Tracking Transparency
* **Status**: PASS
* **Evidence**:
  - No advertising SDKs or third-party behavioral tracking trackers are included.
  - `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking: false`, empty tracking domains, and UserDefaults access reason `CA92.1`.
