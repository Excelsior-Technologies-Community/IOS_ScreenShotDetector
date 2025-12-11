 
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

## **C. Detect Screenshots**

You can listen for the system screenshot notification:

```swift
.onReceive(
    NotificationCenter.default.publisher(
        for: UIApplication.userDidTakeScreenshotNotification
    )
) { _ in
    // Handle screenshot here
    // e.g., clear sensitive state, navigate away, lock screen, etc.
}
```

---

## **D. Detect Screen-Recording or Mirroring**

iOS provides:

```swift
UIScreen.main.isCaptured
```

And a notification:

```swift
UIScreen.capturedDidChangeNotification
```

Usage:

```swift
.onReceive(
    NotificationCenter.default.publisher(
        for: UIScreen.capturedDidChangeNotification
    )
) { _ in
    let isRecording = UIScreen.main.isCaptured

    if isRecording {
        // Screen recording or mirroring started
        // Option: hide UI or show black overlay
    } else {
        // Recording stopped
    }
}
```

### Example: hide UI during recording

```swift
if UIScreen.main.isCaptured {
    Color.black.ignoresSafeArea()   // Hide everything
} else {
    ScreenshotProtectedView {
        YourMainView()
    }
}
```

---

#  **Component Overview (Toast-Free Version)**

## **1. ScreenshotProtectedView**

* Type: `UIViewRepresentable`
* Wraps a SwiftUI view inside a secure UIKit view.
* Prevents protected content from being visible in screenshots.

**Use it for:**

* Banking information
* OTP screens
* QR codes
* Sensitive documents
* Confidential business data

---

## **2. ProtectedView (UIKit Core)**

* A custom UIKit view used internally.
* Contains a `UITextField` with `isSecureTextEntry = true`.
* SwiftUI content is placed inside the secure area of that text field.
* iOS does not include secure text content in screenshots.

You **do not** normally need to interact with this directly.

---

## **3. Screenshot Detection Logic**

### iOS sends a notification **after** the screenshot is taken:

```swift
UIApplication.userDidTakeScreenshotNotification
```

Use `.onReceive` to respond.

---

## **4. Screen Recording Detection Logic**

### To know if the screen is recorded or mirrored:

```swift
UIScreen.main.isCaptured
```

To detect changes:

```swift
UIScreen.capturedDidChangeNotification
```

Apps often hide sensitive UI while recording:

```swift
if UIScreen.main.isCaptured {
    Color.black.ignoresSafeArea()
} else {
    ScreenshotProtectedView {
        SecureContent()
    }
}
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

### **Step 4 — Add screenshot/recording detection (optional)**

```swift
.onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
    // handle screenshot
}

.onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
    let recording = UIScreen.main.isCaptured
}
```

---

# x **Limitations (iOS Platform Rules)**

* iOS does **not allow blocking** the screenshot action.

* Instead, we hide the content **before it reaches the screenshot buffer**.

* Works for:

  * Screenshots
  * Screen recording
  * Screen mirroring (AirPlay)

* Behavior may vary across iOS updates because it uses secure text field mechanisms.

---
 
