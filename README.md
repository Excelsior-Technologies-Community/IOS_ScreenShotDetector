## Screenshot & Screen-Recording Protection – Developer Guide

---

## Quick Start for New Project (Beginner)

### A. Install via GitHub (Swift Package Manager) – Recommended

1. **Add the package dependency**
   - In Xcode, open your app project.
   - Go to: `Project Navigator` → click your **project name** (top) → select your **app target**.
   - Open the **Package Dependencies** tab (or use menu `File > Add Packages...`).
   - In the search field, paste this GitHub URL:
     - `https://github.com/Excelsior-Technologies-Community/excelsior-Technologies-Community-IOS_ScreenShotDetector.git`
   - On the right side:
     - Set **Dependency Rule** to **Branch**.
     - Enter **`Mater`** as the branch name.
   - Click **Add Package**.
   - In the dialog, make sure the library product **`ScreenshotDetectorKit`** is checked for your app target.

2. **Use it in code (basic example)**
   - In any SwiftUI file where you want protection, e.g. `MySecureScreen.swift`:

   ```swift
   import SwiftUI
   import ScreenshotDetectorKit

   struct MySecureScreen: View {
       var body: some View {
           ScreenshotProtectedView {
               Text("Secret info")
           }
       }
   }
   ```

   - That’s all the app developer needs to do for basic protection: **add the GitHub URL as a package**, then `import ScreenshotDetectorKit` and wrap sensitive UI with `ScreenshotProtectedView`.

3. **(Optional) Show your own toast when a screenshot is taken**
   - If your app already has its own toast system (for example a `ToastManager`), you can listen for the screenshot notification and trigger your toast:

   ```swift
   import SwiftUI
   import ScreenshotDetectorKit

   struct ContentView: View {
       @EnvironmentObject var toast: ToastManager   // your own toast manager

       var body: some View {
           ScreenshotProtectedView {
               // Your existing UI
               ScrollView {
                   VStack {
                       Text("Protected Screen")
                           .font(.title.bold())
                           .padding(.top, 40)
                       // ... rest of your content ...
                   }
                   .padding()
               }
           }
           .onReceive(
               NotificationCenter.default.publisher(
                   for: UIApplication.userDidTakeScreenshotNotification
               )
           ) { _ in
               toast.show(.warning, "Screenshot detected - content is protected")
           }
       }
   }
   ```

   - Replace `ToastManager` and `toast.show(...)` with whatever toast / banner system your app already uses.

---

### B. Local file integration (simple copy‑paste option)

1. **Add files to your project**
   - Drag these files into your new SwiftUI app in Xcode:  
     - `ScreenshotDetectorHelper.swift`  

   - Make sure both files are checked for your app target (Target Membership).

2. **Show the ready-made protected screen**
   - In your app entry file (for example `YourApp.swift`), use:

   ```swift
   import SwiftUI

   @main
   struct YourApp: App {
       var body: some Scene {
           WindowGroup {
               HomePage() // already protected + shows toasts
           }
       }
   }
   ```

3. **Protect your own screen (instead of HomePage)**
   - In any new SwiftUI view:

   ```swift
   import SwiftUI

   struct MySecureScreen: View {
       var body: some View {
           ScreenshotProtectedView {
               // Put sensitive UI here
               Text("Secret info")
           }
       }
   }
   ```

   - Everything inside `ScreenshotProtectedView { ... }` will **not appear in screenshots**.

4. **(Optional) Show a small message when screenshot is taken**
   - Use the `HomePage` file as an example: it shows how to use `ToastView`
     and `.onReceive(UIApplication.userDidTakeScreenshotNotification)` to show
     a short “Screenshot detected” popup.

---

This project provides a small set of Swift / SwiftUI utilities to:

- **Hide sensitive UI from screenshots** (by rendering it inside a secure UIKit view).
- **Detect screenshots and screen recording/mirroring** and show a toast-style message.

All of this is implemented using:

- `ScreenShotDetector/ScreenshotDetectorHelper.swift` (core helper types)
- `ScreenShotDetector/HomePage.swift` (example usage screen)

---

## 1. Overview of Components

### ToastView

- **Location**: `ScreenshotDetectorHelper.swift`
- **Type**: `struct ToastView: View`
- **Purpose**: A simple reusable **toast / banner** UI for short messages (e.g. “Screenshot detected”).
- **How it looks**:
  - Black rounded rectangle with white text.
  - Uses `.font(.callout)` with padding and shadow.

**Usage example** (inside any `View`):

```swift
ToastView(message: "Screenshot detected - Content Hidden")
```

Normally you show / hide this with some `@State` boolean and an animation (see `HomePage`).

---

### ScreenshotProtectedView

- **Location**: `ScreenshotDetectorHelper.swift`
- **Type**: `struct ScreenshotProtectedView<Content: View>: UIViewRepresentable`
- **Purpose**: A **SwiftUI wrapper** around a special UIKit view (`ProtectedView`) that makes its content render as if it were inside a secure text field. This prevents the content from appearing in screenshots and (most) screen recordings.

**Key points**:

- Takes a SwiftUI `content` closure (like a `ZStack`, `VStack`, etc.).
- Internally creates a `UIHostingController` for your SwiftUI view.
- Inserts that hosting view into `ProtectedView.secureContentView`, which is the secure area of a `UITextField` with `isSecureTextEntry = true`.

**Basic usage**:

```swift
ScreenshotProtectedView {
    VStack {
        Text("Sensitive data here")
        // ... any other SwiftUI content
    }
}
```

Anything you put inside the `ScreenshotProtectedView` content closure is **protected from screenshots**.

---

### ProtectedView (UIKit)

- **Location**: `ScreenshotDetectorHelper.swift`
- **Type**: `class ProtectedView: UIView`
- **Purpose**: The **low-level UIKit implementation** that enables screenshot protection.

**How it works**:

- Creates a `UITextField` and sets `isSecureTextEntry = true`.
- Grabs the text field’s first subview (the internal “secure” rendering view) and calls it `secureContentView`.
- Adds the `UITextField` to the view hierarchy and pins it to fill the entire `ProtectedView` with Auto Layout.
- Also pins `secureContentView` to fill the entire text field.
- When `contentView` is set, it adds that view **inside** `secureContentView` and pins it with constraints.

Because `secureContentView` is part of a secure text field, its contents **do not appear in screenshots** on iOS. Your SwiftUI content is hosted inside this secure area.

> **Important**: This relies on UIKit’s current internal structure of `UITextField` (using its first subview). If Apple changes this internal implementation in the future, this technique might need updating.

---

### HomePage (Example Screen)

- **Location**: `HomePage.swift`
- **Type**: `struct HomePage: View`
- **Purpose**: An **example SwiftUI screen** that:
  - Shows some sample “sensitive” content wrapped in `ScreenshotProtectedView`.
  - Detects **screenshots** and **screen recording / mirroring**.
  - Shows a `ToastView` with different messages for each event.

**State properties**:

- `@State private var showToast: Bool` – controls whether the toast is visible.
- `@State private var toastMessage: String` – text to show in the toast.
- `@State private var isScreenCaptured: Bool = UIScreen.main.isCaptured` – tracks if the screen is currently being recorded / mirrored.

**Body layout**:

- Uses a top-level `ZStack`.
- If `isScreenCaptured == true`:
  - Fills the screen with `Color.black.ignoresSafeArea()` to hide all content during recording/mirroring.
- Else:
  - Wraps the main content in `ScreenshotProtectedView { ... }`, so that the content is protected from screenshots.
  - Example content: title text, user icon, and description message.
- Overlays `ToastView` at the top when `showToast` is `true`.

**Screenshot & recording detection**:

- **Screenshot**:

  ```swift
  .onReceive(
      NotificationCenter.default.publisher(
          for: UIApplication.userDidTakeScreenshotNotification
      )
  ) { _ in
      showToast(with: "Screenshot detected - Content Hidden")
  }
  ```

- **Screen recording / mirroring**:

  ```swift
  .onReceive(
      NotificationCenter.default.publisher(
          for: UIScreen.capturedDidChangeNotification
      )
  ) { _ in
      let captured = UIScreen.main.isCaptured
      isScreenCaptured = captured
      if captured {
          showToast(with: "Screen recording detected")
      } else {
          showToast(with: "Screen recording stopped")
      }
  }
  ```

**Toast helper**:

```swift
private func showToast(with message: String) {
    toastMessage = message
    showToast = true

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        showToast = false
    }
}
```

---

## 2. How to Integrate into Another Project

### Step 1 – Add the Files

1. Copy the following files into your Xcode project:
   - `ScreenshotDetectorHelper.swift` (contains `ToastView`, `ScreenshotProtectedView`, `ProtectedView`)
   - `HomePage.swift` (example screen using the protection logic)
2. Make sure they are included in your app target in the “Target Membership” settings.

---

### Step 2 – Use `HomePage` as Your Main Screen (optional)

In your `App` entry file (e.g. `ScreenShotDetectorApp.swift`), set `HomePage()` as the root view:

```swift
import SwiftUI

@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            HomePage()
        }
    }
}
```

This will give you a working example with:

- Protected content.
- Screenshot detection.
- Screen recording / mirroring detection.
- Toast messages.

---

### Step 3 – Protect Your Own View

If you already have your own SwiftUI screen, you **do not have to use `HomePage`**. You can:

1. Import `ScreenshotProtectedView` from `ScreenshotDetectorHelper.swift`.
2. Wrap the sensitive part of your view with `ScreenshotProtectedView`.

**Example**:

```swift
struct MySecureScreen: View {
    var body: some View {
        ScreenshotProtectedView {
            VStack(spacing: 16) {
                Text("Bank Account Details")
                    .font(.title)
                // Your sensitive UI here
            }
        }
        .ignoresSafeArea() // optional, depending on your layout
    }
}
```

Everything inside `ScreenshotProtectedView` will be hidden in screenshots.

---

### Step 4 – Add Screenshot / Recording Detection to Any View

You can reuse the logic from `HomePage` in any of your views.

**Minimal pattern**:

```swift
struct MyView: View {
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isScreenCaptured = UIScreen.main.isCaptured

    var body: some View {
        ZStack {
            // Your main content

            if showToast {
                VStack {
                    ToastView(message: toastMessage)
                        .padding(.top, 40)
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.25), value: showToast)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            showToast(with: "Screenshot detected")
            // Optionally: clear / mask sensitive state here
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            let captured = UIScreen.main.isCaptured
            isScreenCaptured = captured
            toastMessage = captured ? "Screen recording detected" : "Screen recording stopped"
            showToast = true
        }
    }

    private func showToast(with message: String) {
        toastMessage = message
        showToast = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}
```

You can customize:

- The messages.
- How long the toast stays visible.
- What extra actions to perform (e.g. navigate away, blur sensitive content, etc.).

---

## 3. Behavior & Limitations

- **Screenshot prevention**:
  - iOS does **not** allow apps to cancel/block a screenshot.
  - This solution instead **prevents your content from being captured** by drawing it in a secure text field’s layer.
- **Recording / mirroring**:
  - `UIScreen.main.isCaptured` tells you when the display is being recorded or mirrored.
  - In `HomePage`, the entire screen is replaced with black while recording is active.
- **Design flexibility**:
  - You can style your protected content however you like inside `ScreenshotProtectedView`.
  - You can swap out `ToastView` for any other notification UI if you prefer.

---

## 4. Quick Checklist for Another Developer

- **To protect a view from screenshots**:
  - Use `ScreenshotProtectedView { ... }` and put your sensitive SwiftUI content inside.
- **To detect screenshots**:
  - Listen to `UIApplication.userDidTakeScreenshotNotification` via `.onReceive`.
- **To detect screen recording / mirroring**:
  - Check `UIScreen.main.isCaptured` and listen to `UIScreen.capturedDidChangeNotification`.
- **To show user feedback**:
  - Use `ToastView` (or replace it with your own component) driven by `@State` and timers.

Give this file to any developer and they should be able to:

- Understand what each component does.
- Plug `ScreenshotProtectedView` and the screenshot/recording detection into their own SwiftUI screens.
- Customize the UI and behavior as needed for their app.

---

## 5. Using This as a Dependency (Swift Package) – High Level

If you want other apps to use this via a **dependency** (not by copying files), you can turn the helper into a **Swift Package**:

1. **Create a new Swift Package (library)**
   - In Xcode: `File > New > Package...`, name it for example `ScreenshotDetectorKit`.
   - In the package’s `Sources/ScreenshotDetectorKit` folder, add a Swift file and move the code from `ScreenshotDetectorHelper.swift` into it.
   - Mark the types as `public`, for example:

   ```swift
   public struct ScreenshotProtectedView<Content: View>: UIViewRepresentable { ... }
   public struct ToastView: View { ... }
   public final class ProtectedView: UIView { ... }
   ```

2. **Host the package in Git (optional but recommended)**
   - Put the package in a Git repo (e.g. GitHub).
   - Other developers can then add it using the repo URL.

3. **Add the package to any app**
   - In the app project: `File > Add Packages...`
   - Enter the Git URL of your package (or choose a local package folder).
   - Add the library product (e.g. `ScreenshotDetectorKit`) to the app target.

4. **Use it in the app code**
   - In any SwiftUI file that should use the protection:

   ```swift
   import SwiftUI
   import ScreenshotDetectorKit

   struct MySecureScreen: View {
       var body: some View {
           ScreenshotProtectedView {
               Text("Secret info")
           }
       }
   }
   ```

This way, other developers only need to **add the Swift Package dependency and import the module**, instead of copying files manually.


