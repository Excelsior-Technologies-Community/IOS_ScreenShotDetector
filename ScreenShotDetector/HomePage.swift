//
// HomePage.swift
// ScreenShotDetector
//
// Created by YourName on 04/12/25.
//

import SwiftUI

// Assuming ToastView, ScreenshotProtectedView, and ProtectedView
// are accessible in this file (e.g., defined in ScreenshotDetectorHelper.swift
// or their own files, and not marked 'fileprivate').

struct HomePage: View {
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var isScreenCaptured: Bool = UIScreen.main.isCaptured
    
    var body: some View {
        ZStack {
            if isScreenCaptured {
                // Screen Recording/Mirroring protection (same as before)
                Color.black
                    .ignoresSafeArea()
            } else {
                // Screenshot Protection wrapper
                ScreenshotProtectedView {
                    // --- PLACE YOUR SENSITIVE HOME PAGE CONTENT HERE ---
                    VStack(spacing: 20) {
                        Text("Welcome, User!")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.purple)
                      

                        Text("This content is protected from screenshots.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                    // ---------------------------------------------------
                }
                .ignoresSafeArea()
            }
            
            // Toast overlay (reusable logic)
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
        // Listen for system screenshot notification (reusable logic)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ in
            showToast(with: "Screenshot detected - Content Hidden")
        }
        // Listen for screen recording / mirroring state (reusable logic)
        .onReceive(NotificationCenter.default.publisher(for: UIScreen.capturedDidChangeNotification)) { _ in
            let captured = UIScreen.main.isCaptured
            isScreenCaptured = captured
            if captured {
                showToast(with: "Screen recording detected")
            } else {
                showToast(with: "Screen recording stopped")
            }
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

#Preview {
    HomePage()
}
