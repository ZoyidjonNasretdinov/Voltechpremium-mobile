# Apple Submission Final Checklist — Völtech Premium (v1.0.2 Build 11)

Use this operational checklist before triggering the final submission in App Store Connect:

---

### ACCOUNT
- [x] Login verified with phone + password
- [x] Registration verified with essential fields only (Phone, Name, Password)
- [x] Date of birth / Age is optional
- [x] Region is optional
- [x] District is optional
- [x] Logout clears tokens and redirects to Login
- [x] Account Deletion option visible in Settings list
- [x] Account Deletion confirmation dialog displays warning
- [x] Account Deletion backend call executes and completely erases user data
- [x] Local secure storage wiped upon deletion

---

### PRIVACY & PERMISSIONS
- [x] Privacy Policy accessible in-app without login (`Profile → Policy`)
- [x] Privacy Policy text reflects optional demographic data
- [x] `NSCameraUsageDescription` is concise and user-facing
- [x] `NSPhotoLibraryUsageDescription` is concise and user-facing
- [x] No unused permissions in `Info.plist`
- [x] `PrivacyInfo.xcprivacy` present and valid
- [x] Tracking is disabled (`NSPrivacyTracking: false`)
- [x] No third-party ad or tracking SDKs in mobile dependencies

---

### PAYMENTS & COMMERCE
- [x] No digital in-app purchase bypass
- [x] Loyalty rewards are strictly physical items redeemed via points
- [x] Points cannot be purchased with fiat money

---

### QUALITY & PLATFORM SUPPORT
- [x] Tested on iPhone and iPad screen sizes
- [x] Added `UIRequiresFullScreen` for iPadOS stability
- [x] Centered responsive layouts (`maxWidth` constraints) on iPad
- [x] No debug console output exposed to users
- [x] Offline connectivity banner and network retry logic active
- [x] 13/13 automated test cases passing (`flutter test`)
- [x] 0 analyzer warnings (`flutter analyze`)

---

### METADATA & REVIEW COLLATERAL
- [ ] Version in App Store Connect set to `1.0.2` (Build 11)
- [ ] What's New notes updated
- [ ] Demo account credentials entered in App Review Information
- [ ] Review Notes text copied from `APP_REVIEW_NOTES.md`
- [ ] Screen recording video captured on physical device and linked/attached
