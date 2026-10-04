# macOS Handoff & iOS Testing Guide

This guide provides instructions for checking out and running the **DoseMate iOS native application** on macOS using Apple Xcode and the iOS Simulator.

---

## 1. Prerequisites

- **Host Machine:** macOS Sonoma 14.0+ or macOS Sequoia 15.0+
- **Tooling:** Apple Xcode 15.0+ (Command Line Tools installed)
- **Runtime:** iOS 17.0+ Simulator SDK

---

## 2. Quickstart Execution Commands

```bash
# 1. Clone the repository
git clone https://github.com/Burhan9464/DoseMate.git
cd DoseMate

# 2. Navigate to the iOS project directory
cd ios/DoseMate

# 3. Open directly in Xcode
open DoseMate.xcodeproj
```

Or build directly via terminal using `xcodebuild`:
```bash
xcodebuild -project DoseMate.xcodeproj \
           -scheme DoseMate \
           -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
           build
```

---

## 3. Backend Connectivity

- **iOS Simulator to Local Backend:**
  By default, `APIConstants.baseURL` points to `http://localhost:8080/api/v1`. On macOS, the iOS Simulator shares the host network loopback interface, allowing it to communicate with the Spring Boot backend running on port 8080 without extra configuration.
  
- **Physical iPhone Device Testing:**
  When deploying to a physical test device via Xcode, configure `DOSEMATE_API_URL` environment variable in your Xcode scheme:
  ```text
  DOSEMATE_API_URL = http://<YOUR_LOCAL_IP>:8080/api/v1
  ```

---

## 4. Multi-Viewport Responsive Matrix

Test the interface across the 5 reference iPhone viewports to verify adaptive layout:

| Device Target | Viewport Size (pt) | Scale Factor | Key Verification Checks |
|---|---|---|---|
| **iPhone SE (3rd Gen)** | 375 × 667 | @2x | Compact screen, button heights, scrolling without truncation |
| **iPhone 13 / 14 / 15** | 390 × 844 | @3x | Standard Dynamic Island / notch spacing |
| **iPhone 15 Pro** | 393 × 852 | @3x | 120Hz ProMotion Drag-the-Pill smooth 60/120fps gesture |
| **iPhone 14 Plus / 15 Plus**| 428 × 926 | @3x | Wide cards, grid adherence ring proportions |
| **iPhone 15 / 16 Pro Max** | 430 × 932 | @3x | Large display hierarchy, modal sheet heights |

---

## 5. Verification Checklist on macOS

- [ ] **Splash & Session:** App opens with branded splash animation and evaluates existing session or routes to Onboarding.
- [ ] **Onboarding & Guide:** 3-page swipeable onboarding; skipping navigates to authentication. Interactive guide 5-step walkthrough displays on first registration.
- [ ] **2-Step Registration:** Full name, email, password validation -> DOB, gender, and searchable country selector with emoji flags.
- [ ] **Drag-the-Pill Gesture:** Horizontal drag snaps at 72% threshold, triggers `UIImpactFeedbackGenerator`, commits taken state, and atomically decrements inventory.
- [ ] **Skip & Undo:** Skipping a due dose shows the 15-minute undo snackbar; tapping Undo restores the dose to Pending.
- [ ] **Medication CRUD:** Add medication with 3-step wizard (Info, Schedule, Inventory); pause/resume toggling cancels/re-registers local notifications.
- [ ] **History & Search:** Doses grouped by relative date headers ("Today", "Yesterday"); filter by ALL, TAKEN, SKIPPED, MISSED.
