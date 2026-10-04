import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: SpacingTokens.lg) {
                // Status Card
                VStack(spacing: SpacingTokens.md) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.12))
                            .frame(width: 72, height: 72)
                        Image(systemName: statusIcon)
                            .font(.system(size: 32))
                            .foregroundColor(statusColor)
                    }
                    
                    VStack(spacing: SpacingTokens.xs) {
                        Text(statusTitle)
                            .font(TypographyTokens.title2)
                            .foregroundColor(ColorTokens.textPrimary)
                        Text(statusDescription)
                            .font(TypographyTokens.body)
                            .foregroundColor(ColorTokens.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SpacingTokens.md)
                    }
                    
                    if viewModel.authorizationStatus == .denied {
                        PrimaryButton(title: "Open iOS Settings", icon: "gear") {
                            viewModel.openSystemSettings()
                        }
                        .padding(.top, SpacingTokens.xs)
                    } else if viewModel.authorizationStatus == .notDetermined {
                        PrimaryButton(title: "Enable Dose Reminders", icon: "bell.badge.fill") {
                            Task {
                                await viewModel.requestPermission()
                            }
                        }
                        .padding(.top, SpacingTokens.xs)
                    }
                }
                .cardStyle(padding: SpacingTokens.lg)
                
                // Explanatory Info Card
                VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                    Text("How DoseMate Reminders Work")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Divider()
                    
                    explanationBullet(
                        icon: "calendar.badge.clock",
                        title: "Schedule-Driven",
                        desc: "Local alarms are scheduled automatically based on your active medications."
                    )
                    
                    explanationBullet(
                        icon: "bell.slash.fill",
                        title: "Smart Muting",
                        desc: "Pausing or deleting a medication immediately cancels all its future alarms."
                    )
                    
                    explanationBullet(
                        icon: "hand.tap.fill",
                        title: "Manual Fallback",
                        desc: "Even if notifications are disabled, you can always track your doses in the app."
                    )
                }
                .cardStyle(padding: SpacingTokens.lg)
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.bottom, SpacingTokens.xxl)
        }
        .background(ColorTokens.background.ignoresSafeArea())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.checkStatus()
        }
    }
    
    private var statusColor: Color {
        switch viewModel.authorizationStatus {
        case .authorized, .provisional:
            return ColorTokens.statusTaken
        case .denied:
            return ColorTokens.statusMissed
        default:
            return ColorTokens.statusWarning
        }
    }
    
    private var statusIcon: String {
        switch viewModel.authorizationStatus {
        case .authorized, .provisional:
            return "bell.badge.fill"
        case .denied:
            return "bell.slash.fill"
        default:
            return "bell.fill"
        }
    }
    
    private var statusTitle: String {
        switch viewModel.authorizationStatus {
        case .authorized, .provisional:
            return "Reminders are Active"
        case .denied:
            return "Reminders are Disabled"
        default:
            return "Reminders Not Set Up"
        }
    }
    
    private var statusDescription: String {
        switch viewModel.authorizationStatus {
        case .authorized, .provisional:
            return "You will receive timely local alerts on this device whenever a scheduled dose is due."
        case .denied:
            return "Notifications are turned off in iOS Settings. Tap below to enable notifications so you never miss a dose."
        default:
            return "Grant notification access to receive alerts when your medications are due."
        }
    }
    
    private func explanationBullet(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: SpacingTokens.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.primaryTeal)
                .frame(width: 24)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(TypographyTokens.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorTokens.textPrimary)
                Text(desc)
                    .font(TypographyTokens.footnote)
                    .foregroundColor(ColorTokens.textSecondary)
            }
        }
        .padding(.vertical, 2)
    }
}
