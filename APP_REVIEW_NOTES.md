# App Review Notes — Völtech Premium

**Application Name**: Völtech Premium  
**Platform**: iOS & iPadOS  
**Version**: 1.0.2  
**Build**: 11  
**Bundle ID**: `com.voltech.premium`  

---

## 1. Demo Credentials for App Review Team
* **Phone Number**: `+998991234569`
* **Demo OTP**: `814629`
* **Auto Approve**: Enabled (account is automatically approved upon OTP verification)
* *Note: `DEMO_MODE_PASSWORD` is omitted/empty so testing can register freshly or reset anytime.*

---

## 2. Core App Functionality
Völtech Premium is an official customer loyalty platform for purchasers of authentic Völtech products.
1. **Earn Points**: Customers purchase genuine Völtech products with unique QR codes. By scanning the QR code with the in-app camera scanner (or manual entry), reward points are credited to their account.
2. **Redeem Physical Gifts**: Accumulated points are exchanged for physical merchandise and reward products in the "Sovg'alar" (Gifts) catalog. The company fulfills and delivers physical gifts to approved customers.
3. **No Digital Goods / IAP**: The app does **not** sell digital content, subscriptions, credits, or virtual goods. Points cannot be purchased with money; they are exclusively earned from physical product purchases.
4. **Card Customization & Points History**: Users can customize their virtual membership card theme and track all bonus earnings and redemptions.

---

## 3. Account Deletion Guide (Guideline 5.1.1(v))
Account deletion is accessible inside the app without contacting support:
- **Primary Path**: Profile / Settings (top right icon on Home) → Scroll down to **"Hisobni o'chirish" / "Delete Account"** (prominently styled in red with a trash icon).
- **Secondary Path**: Profile → General Settings (Edit Profile) → **"Delete Account"**.
- Tapping this option prompts a clear confirmation warning. Upon confirmation, the backend `DELETE /api/v1/profile` endpoint permanently erases the user's account, credentials, and points, clears local session storage, and routes the user back to the Login screen.
- A physical device video recording link is provided in the Review Notes / Attachments.

---

## 4. Personal Data Minimization Notice (Guideline 5.1.1(v))
- Registration and account creation strictly require only **Phone Number**, **First Name**, **Last Name**, and **Password**.
- Non-essential personal demographic fields (**Date of Birth / Age**, **Region**, **District**) have been completely removed from the registration and profile editing flows.

---

## 5. Review Testing Codes for QR Scanner
To test the QR activation functionality without a physical product package, open the **Scanner** tab, tap **Manual Entry**, and enter any of the review QR test codes:
- Code 1: `[CODE_1]`
- Code 2: `[CODE_2]`
- Code 3: `[CODE_3]`
*(Note: each unique QR code can be activated only once).*
