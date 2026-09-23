# App Store Review submission checklist

Before submitting, configure the production backend with a **single** review-only
phone number and keep the service available throughout review:

```text
DEMO_MODE_ENABLED=true
DEMO_MODE_PHONE=+998991234569
DEMO_MODE_OTP=814629
DEMO_MODE_AUTO_APPROVE=true
JWT_SECRET=<at-least-32-byte-secret>
ADMIN_PHONE_NUMBER=<admin-phone>
ADMIN_PASSWORD=<strong-admin-password>
ESKIZ_EMAIL=<sms-account-email>
ESKIZ_PASSWORD=<sms-account-password>
GCP_CREDENTIALS_PATH=<absolute-path-to-service-account-json>
```
*Eslatma: `DEMO_MODE_PASSWORD` o'chirib tashlangan yoki bo'sh qoldirilgan.*

`DEMO_MODE_PHONE` (+998991234569) is the only number that can register without a real SMS. It
must use the configured `DEMO_MODE_OTP` (814629) and is automatically approved, without
an administrator action. The number is not created at backend startup, so it
can be used for the registration flow. Do not use a real customer number.

Paste and complete the following in **App Review Information → Notes**:

```text
Völtech Premium is a loyalty application for customers who purchase our products.

Review account / Demo Registration:
Phone: +998991234569
Demo OTP: 814629

If a new account is needed, use the demo phone above and OTP: 814629.
The demo account is automatically approved. Other registrations require SMS
verification and administrator approval.

To test QR activation, open Scanner and use Manual Entry with these unused
review codes: [CODE_1], [CODE_2], [CODE_3]. A code can be activated only once.

Gifts are physical loyalty rewards redeemed using points earned from product
QR codes. The app has no in-app payment, subscription, or digital-content sale.

Account deletion is readily available directly in the app:
- Path 1: Profile (Settings icon) → Scroll to "Delete Account" (highlighted in red with trash icon)
- Path 2: Profile → General Settings (Edit Profile) → "Delete Account"
When confirmed, all user data, credentials, and points are permanently erased and the session returns to the login screen.

Data Collection Notice (Guideline 5.1.1(v)):
Age, Region, and District are strictly optional during registration and profile management. Only First Name, Last Name, Phone Number, and Password are required.
```

## Screen Recording Instructions (Required by Apple Review Team)
Apple requested a screen recording captured on a physical device demonstrating:
1. Creating a new account or signing in with the demo account.
2. Navigating to the account deletion option.
3. The complete account deletion flow from initiation to confirmation.

**How to record and upload:**
- On your iPhone or iPad, go to **Settings → Control Center → Screen Recording** (enable it).
- Start screen recording.
- Open **Völtech Premium** (version 1.0.2 build 11).
- Sign in with the demo account (or register with the demo phone and OTP).
- Tap the **Profile / Settings** icon on the top right.
- Show the **"Delete Account"** option in the settings list.
- Tap **"Delete Account"**.
- The confirmation dialog appears with warning text explaining that data and points will be erased.
- Tap **"Delete Account"** in the dialog to confirm.
- Observe the success notification and the app returning to the Login screen.
- Stop recording.
- Upload this video to a public link (or attach directly in App Store Connect Notes / Attachment).

## Reply to App Review in App Store Connect:
Copy and paste the response below in the App Store Connect Resolution Center:

```text
Dear App Review Team,

Thank you for your review and feedback. We have addressed both issues under Guideline 5.1.1(v) in version 1.0.2 (Build 11):

1. Non-essential Personal Information (Age/Date of Birth, Region, District):
We have updated the app so that Date of Birth / Age, Region, and District have been completely removed from the registration and profile editing screens. Users can register and use all features of the app with only their Name, Phone Number, and Password. Our Privacy Policy has also been updated accordingly.

2. Account Deletion:
The app supports complete in-app account deletion. Users can initiate account deletion directly from the primary Settings screen (Profile → Delete Account) as well as from Edit Profile. Upon confirmation in the alert dialog, the user's personal details, credentials, and loyalty points are permanently deleted from our database and the user is redirected to the login screen.

We have attached a screen recording demonstrating the complete account deletion flow as requested (or provided a link in the Review Notes).

Demo Account Credentials for Review:
Phone: [DEMO_PHONE]
Password: [DEMO_PASSWORD]
Demo Registration OTP: [DEMO_OTP]

Thank you for your time and guidance.
```
