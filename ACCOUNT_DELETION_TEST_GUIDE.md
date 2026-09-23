# Account Deletion Test & Video Recording Guide

This document provides step-by-step instructions to record the physical-device video required by the Apple App Review team for **Guideline 5.1.1(v) - Data Collection and Storage (Account Deletion)**.

---

## 1. Recording Setup & Requirements
* **Device**: Physical iPhone or iPad (Apple specifically reviewed on iPad Air 11-inch (M3)).
* **App Version**: 1.0.2 (Build 11).
* **Format**: MP4 / MOV.
* **Duration**: 45–90 seconds.
* **Video Content**:
  1. Login with the demo account (or registration with demo phone + OTP).
  2. Navigation to the Account Deletion option.
  3. Opening the confirmation dialog.
  4. Confirming deletion.
  5. Successful account removal and automatic return to the Login screen.

---

## 2. Step-by-Step Recording Procedure

### Step 1: Enable Screen Recording
- Go to iOS **Settings → Control Center**.
- Ensure **Screen Recording** is added to the active controls.
- Swipe down from the top-right corner to open Control Center and tap the **Record** icon (3-second countdown).

### Step 2: Open App and Sign In
- Launch **Völtech Premium**.
- On the Login screen, enter the review credentials:
  - **Phone**: `[DEMO_PHONE]`
  - **Password**: `[DEMO_PASSWORD]`
- Tap **"Tizimga kirish" / "Login"**.
- The Home screen opens displaying the user's loyalty card and points.

### Step 3: Navigate to Account Deletion
- Tap the **Profile / Settings** icon (gear or profile avatar) in the top-right corner of the Home screen.
- Scroll down past General Settings and Legal policies.
- Clearly show the prominent **"Hisobni o'chirish" / "Delete Account"** option with the red trash icon.

### Step 4: Trigger Deletion Confirmation
- Tap **"Hisobni o'chirish" / "Delete Account"**.
- The confirmation dialog appears with the warning:
  > *"Haqiqatan ham hisobingizni o'chirmoqchimisiz? Barcha ma'lumotlaringiz, to'plangan ballaringiz va skanerlash tarixi butunlay o'chiriladi. Bu amalni ortga qaytarib bo'lmaydi."*
  > *(Are you sure you want to delete your account? All your personal data, accumulated points, and scan history will be permanently erased. This action cannot be undone.)*

### Step 5: Confirm Deletion
- Tap the red **"Hisobni o'chirish" / "Delete Account"** button inside the dialog.
- The loading indicator appears briefly while `DELETE /api/v1/profile` is executed.
- A green confirmation notification (**"Hisobingiz muvaffaqiyatli o'chirildi" / "Your account has been successfully deleted"**) appears at the bottom.
- The app automatically navigates back to the **Login screen** with local tokens and credentials completely wiped.

### Step 6: Stop Recording
- Open Control Center and tap the red recording indicator to stop recording.
- Save the video to the Photos library.

---

## 3. How to Submit the Video to Apple

1. **Option A (Direct in App Store Connect - Recommended)**:
   - In App Store Connect, go to **Apps → Völtech Premium → App Review Information**.
   - In the **Notes** field, provide a direct streaming or download link (e.g. iCloud Link, Google Drive, or Dropbox with public view permissions).

2. **Option B (Resolution Center Reply)**:
   - In App Store Connect → **Resolution Center**, reply to Apple's message and attach the video file directly (or paste the cloud link if file size exceeds attachment limit).
