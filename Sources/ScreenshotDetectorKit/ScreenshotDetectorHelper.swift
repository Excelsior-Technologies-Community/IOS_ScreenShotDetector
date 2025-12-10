//
// ScreenshotDetectorHelper.swift
// ScreenshotDetectorKit (Swift Package)
//

import SwiftUI
import UIKit

// Simple toast style view
public struct ToastView: View {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        Text(message)
            .font(.callout)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.85))
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(radius: 6)
    }
}

// Screenshot Protection View
public struct ScreenshotProtectedView<Content: View>: View {
    @StateObject private var detector = ScreenshotDetector()
    public let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ZStack {
            ProtectedRepresentable(content: content)

            if detector.didTakeScreenshot {
                ToastView(message: "Screenshot is not allowed!")
                    .transition(.opacity)
                    .padding(.top, 50)
            }
        }
        .onAppear {
            detector.onScreenshot = {
                print("⚠️ Screenshot Detected!")
            }
        }
    }
}
public struct ProtectedRepresentable<Content: View>: UIViewRepresentable {
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public func makeUIView(context: Context) -> UIView {
        let view = ProtectedView()

        let hosting = UIHostingController(rootView: content)
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        view.contentView = hosting.view
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {}
}


// UIKit view that hosts the secure content
public final class ProtectedView: UIView {
    var contentView: UIView? {
        didSet {
            // Remove old content and add new content when set
            oldValue?.removeFromSuperview()
            if let newContent = contentView {
                secureContentView.addSubview(newContent)
                
                newContent.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    newContent.leadingAnchor.constraint(equalTo: secureContentView.leadingAnchor),
                    newContent.trailingAnchor.constraint(equalTo: secureContentView.trailingAnchor),
                    newContent.topAnchor.constraint(equalTo: secureContentView.topAnchor),
                    newContent.bottomAnchor.constraint(equalTo: secureContentView.bottomAnchor)
                ])
            }
        }
    }
    
    private let secureTextField = UITextField()
    private var secureContentView: UIView // This will hold the internal secure view
    
    override init(frame: CGRect) {
        secureTextField.isSecureTextEntry = true
        guard let internalSecureView = secureTextField.subviews.first else {
            fatalError("Could not find the internal secure view of UITextField.")
        }
        self.secureContentView = internalSecureView
        
        super.init(frame: frame)
        setupSecureLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSecureLayer() {
        // 1. Add the UITextField to self
        addSubview(secureTextField)
        sendSubviewToBack(secureTextField)
        
        // 2. Set the UITextField to cover the entire view
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 3. Make the internal secure view cover the entire area
        secureContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureContentView.leadingAnchor.constraint(equalTo: secureTextField.leadingAnchor),
            secureContentView.trailingAnchor.constraint(equalTo: secureTextField.trailingAnchor),
            secureContentView.topAnchor.constraint(equalTo: secureTextField.topAnchor),
            secureContentView.bottomAnchor.constraint(equalTo: secureTextField.bottomAnchor)
        ])
    }
    
    // Auto layout keeps everything pinned, but keep this as a safety/fallback.
    public override func layoutSubviews() {
        super.layoutSubviews()
        secureTextField.frame = bounds
    }
}



// MARK: - Screenshot Detection Listener
public final class ScreenshotDetector: ObservableObject {
    @Published public var didTakeScreenshot: Bool = false
    public var onScreenshot: (() -> Void)?

    public init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidTakeScreenshot),
            name: UIApplication.userDidTakeScreenshotNotification,
            object: nil
        )
    }

    @objc private func userDidTakeScreenshot() {
        didTakeScreenshot = true
        onScreenshot?()
        
        // Auto reset after 1 sec
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.didTakeScreenshot = false
        }
    }
}
