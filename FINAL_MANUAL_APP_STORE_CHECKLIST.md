# Final Manual App Store Connect Submission Checklist

This document details all configuration and verification steps that must be completed manually in **App Store Connect** before submitting **Völtech Premium (v1.0.2 Build 11)**.

---

## 1. App Store Metadata (Guideline 2.3)
- [ ] **App Name**: `Völtech Premium`
- [ ] **Subtitle**: Loyalty rewards and product verification for Völtech customers (under 30 chars).
- [ ] **Primary Category**: Shopping or Lifestyle / Utilities.
- [ ] **Description**: Clearly explain that Völtech Premium is a loyalty application for customers who purchase genuine Völtech products to verify originality and earn loyalty points for physical gifts.
- [ ] **Promotional Text / What's New in 1.0.2**:
  - *"Made date of birth, region, and district optional during registration."*
  - *"Enhanced account deletion accessibility directly in profile settings."*
  - *"Optimized layouts for iPad Air and iPadOS devices."*
  - *"General stability and UI performance improvements."*
- [ ] **Keywords**: `voltech, loyalty, qr scanner, rewards, premium, usta, points` (comma-separated, max 100 characters).
- [ ] **Support URL**: Ensure the support URL is live and points to a working support contact page.
- [ ] **Privacy Policy URL**: Ensure the privacy URL is publicly accessible without login and matches the in-app policy.

---

## 2. App Privacy Questions (App Store Privacy Nutrition Labels)
In App Store Connect → **App Privacy**:
- [ ] **Data Used to Track You**: Confirm **No** (the app does NOT track users across third-party apps or websites; `NSPrivacyTracking: false`).
- [ ] **Data Linked to You**:
  - **Contact Info**: Name, Phone Number (used for App Functionality, Account Management).
  - **User Content / Photos**: Photos (used for App Functionality if user chooses to upload an avatar).
  - **Identifiers**: User ID (used for App Functionality).
  - **Purchases**: Purchase History / Loyalty gift redemptions (used for App Functionality).
- [ ] **Data Not Linked to You**: None.
- [ ] **Ensure Optional Fields Notice**: Age, Region, and District are not required.

---

## 3. App Review Information
In App Store Connect → **App Review Information**:
- [ ] **Sign-in Required**: Check **Yes**.
- [ ] **Username**: `+998991234569`
- [ ] **Password**: `Reviewer2026!` (yoki registratsiya orqali yangi yaratilishi mumkin)
- [ ] **Notes**:
  - Demo Phone: `+998991234569`
  - Demo OTP: `814629`
  - *`DEMO_MODE_PASSWORD` olib tashlangan, hisob avtomatik tasdiqlanadi (`auto-approve`).*
- [ ] **Attachment / Video**: Attach the physical device screen recording of the account deletion flow (or provide a streaming link in the Notes field).
- [ ] **Contact Info**: First name, Last name, Phone number, and Email of the developer / submitter for Apple reviewers to reach out if needed.

---

## 4. Age Rating (Guideline 1.7)
- [ ] Ensure age rating questionnaire accurately reflects **4+** (no gambling, no mature content, no alcohol/tobacco, no unrestricted web access).

---

## 5. Export Compliance & Encryption
- [ ] Standard encryption exemption: Selected **No** for non-exempt encryption (matches `<key>ITSAppUsesNonExemptEncryption</key><false/>` in `Info.plist`).
