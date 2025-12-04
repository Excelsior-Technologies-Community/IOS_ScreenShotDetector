//
// ScreenshotDetectorHelper.swift
// ScreenshotDetectorKit (Swift Package)
//

import SwiftUI
import UIKit

// MARK: - Public Toast View
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

// MARK: - Screenshot Protected View
public struct ScreenshotProtectedView<Content: View>: UIViewRepresentable {
    public typealias UIViewType = ProtectedView  // ✅ Now valid because ProtectedView is public
    
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> ProtectedView {
        let protectedView = ProtectedView()
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        protectedView.contentView = hostingController.view
        return protectedView
    }
    
    public func updateUIView(_ uiView: ProtectedView, context: Context) {
        // Update content if needed
    }
}

// MARK: - Protected UIView (Now PUBLIC)
public final class ProtectedView: UIView {
    public var contentView: UIView? {
        didSet {
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
    private var secureContentView: UIView
    
    public override init(frame: CGRect) {
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
        addSubview(secureTextField)
        sendSubviewToBack(secureTextField)
        
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        secureContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secureContentView.leadingAnchor.constraint(equalTo: secureTextField.leadingAnchor),
            secureContentView.trailingAnchor.constraint(equalTo: secureTextField.trailingAnchor),
            secureContentView.topAnchor.constraint(equalTo: secureTextField.topAnchor),
            secureContentView.bottomAnchor.constraint(equalTo: secureTextField.bottomAnchor)
        ])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        secureTextField.frame = bounds
    }
}

// MARK: - Screenshot Detector View Modifier
public struct ScreenshotDetectorModifier: ViewModifier {
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    @Binding var isScreenCaptured: Bool
    
    public init(showToast: Binding<Bool>, toastMessage: Binding<String>, isScreenCaptured: Binding<Bool>) {
        self._showToast = showToast
        self._toastMessage = toastMessage
        self._isScreenCaptured = isScreenCaptured
    }
    
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
                showToastMessage("Screenshot detected - Content Hidden")
            }
            .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
                let captured = UIScreen.main.isCaptured
                isScreenCaptured = captured
                showToastMessage(captured ? "Screen recording detected" : "Screen recording stopped")
            }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

// MARK: - View Extension
public extension View {
    func detectScreenshots(showToast: Binding<Bool>,
                          toastMessage: Binding<String>,
                          isScreenCaptured: Binding<Bool>) -> some View {
        self.modifier(ScreenshotDetectorModifier(
            showToast: showToast,
            toastMessage: toastMessage,
            isScreenCaptured: isScreenCaptured
        ))
    }
}

// MARK: - Complete Protected Screen View
public struct ProtectedScreenView<Content: View>: View {
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var isScreenCaptured: Bool = UIScreen.main.isCaptured
    
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            if isScreenCaptured {
                Color.black
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            Text("Screen Recording Detected")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.top)
                            Text("Content hidden for security")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            } else {
                ScreenshotProtectedView {
                    content
                }
                .ignoresSafeArea()
            }
            
            if showToast {
                VStack {
                    ToastView(message: toastMessage)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 40)
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.25), value: showToast)
            }
        }
        .detectScreenshots(
            showToast: $showToast,
            toastMessage: $toastMessage,
            isScreenCaptured: $isScreenCaptured
        )
    }
}

// MARK: - Package.swift Example
/*
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ScreenshotDetectorKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ScreenshotDetectorKit",
            targets: ["ScreenshotDetectorKit"]),
    ],
    targets: [
        .target(
            name: "ScreenshotDetectorKit",
            dependencies: [])
    ]
)
*/
