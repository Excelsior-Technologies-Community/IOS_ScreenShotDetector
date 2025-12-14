 
#  **Screenshot & Screen-Recording Protection – Developer Guide **

---

## Quick Start for New Project (Beginner)

---

## **A. Install via GitHub (Swift Package Manager)**

1. Open your app in **Xcode**
2. Go to:
   **File → Add Packages…**
3. Paste the GitHub URL:

```
https://github.com/Excelsior-Technologies-Community/IOS_ScreenShotDetector
```

4. Set rule to:
   **Branch → `Master`**
5. Add the library product to your app target:
   **`ScreenshotDetectorKit`**
6. Done — package is now installed.

---

## **B. Basic Usage — Protect Sensitive SwiftUI Screens**

Import the package inside any SwiftUI file:

```swift
import SwiftUI
import ScreenshotDetectorKit
```

Wrap your sensitive UI inside:

```swift
ScreenshotProtectedView {
    // Your confidential UI
    Text("Secret Information")
        .font(.title)
}
```

### ✔ Anything inside `ScreenshotProtectedView` will NOT appear in screenshots.

---

 
---

## **C. Detect Screen-Recording or Mirroring**

iOS provides:

```swift
UIScreen.main.isCaptured
```
 
**Use it for:**

* Banking information
* OTP screens
* QR codes
* Sensitive documents
* Confidential business data

---
  
## **2. Screenshot Detection Logic**

### iOS sends a notification **after** the screenshot is taken:

```swift
UIApplication.userDidTakeScreenshotNotification
```

Use `.onReceive` to respond.

---

## **3. Screen Recording Detection Logic**

### To know if the screen is recorded or mirrored:

```swift
UIScreen.main.isCaptured
```

To detect changes:

```swift
UIScreen.capturedDidChangeNotification
``` 
---

#   **How to Integrate Into Another Project**

### **Step 1 — Add the package** (SPM)

As shown above.

### **Step 2 — Import the module**

```swift
import ScreenshotDetectorKit
```

### **Step 3 — Protect any sensitive view**

```swift
ScreenshotProtectedView {
    VStack {
        Text("Bank Details")
        Text("Account No: XXXX-XXXX-XXXX")
    }
}
```
 

# x **Limitations (iOS Platform Rules)**

* iOS does **not allow blocking** the screenshot action.

* Instead, we hide the content **before it reaches the screenshot buffer**.

* Works for:

  * Screenshots
  * Screen recording
  * Screen mirroring (AirPlay)

* Behavior may vary across iOS updates because it uses secure text field mechanisms.

---
 
