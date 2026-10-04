import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var appState: AppState
    @State private var showLogoutConfirmation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: SpacingTokens.lg) {
                // User Avatar and Name Card
                VStack(spacing: SpacingTokens.sm) {
                    ZStack {
                        Circle()
                            .fill(ColorTokens.brandGradient)
                            .frame(width: 80, height: 80)
                            .shadow(color: ColorTokens.primaryTeal.opacity(0.3), radius: 10, x: 0, y: 4)
                        
                        Text(viewModel.user?.fullName.prefix(1).uppercased() ?? "D")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, SpacingTokens.xs)
                    
                    VStack(spacing: 2) {
                        Text(viewModel.user?.fullName ?? "DoseMate User")
                            .font(TypographyTokens.title2)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        Text(viewModel.user?.email ?? "")
                            .font(TypographyTokens.subheadline)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                .cardStyle(padding: SpacingTokens.lg)
                
                // Personal Details Card
                VStack(alignment: .leading, spacing: SpacingTokens.md) {
                    Text("Personal Details")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Divider()
                    
                    infoRow(title: "Date of Birth", value: viewModel.user?.dateOfBirth ?? "Not set")
                    infoRow(title: "Gender", value: viewModel.user?.gender?.replacingOccurrences(of: "_", with: " ").capitalized ?? "Not set")
                    infoRow(title: "Country", value: viewModel.user?.country ?? "Not set")
                    infoRow(title: "Timezone", value: viewModel.user?.timezone ?? TimeZone.current.identifier)
                }
                .cardStyle(padding: SpacingTokens.lg)
                
                // Settings & Preferences Section
                VStack(spacing: 0) {
                    NavigationLink(destination: NotificationsView()) {
                        settingsRow(icon: "bell.badge.fill", title: "Notifications & Reminders", tint: ColorTokens.primaryTeal)
                    }
                    
                    Divider()
                        .padding(.leading, 48)
                    
                    Button(action: {
                        HapticService.shared.selection()
                        appState.replayGuide()
                    }) {
                        settingsRow(icon: "sparkles", title: "Replay App Guide", tint: ColorTokens.secondarySky)
                    }
                    
                    Divider()
                        .padding(.leading, 48)
                    
                    NavigationLink(destination: EditProfileView(user: viewModel.user) {
                        Task { await viewModel.loadProfile() }
                    }) {
                        settingsRow(icon: "person.crop.circle.badge.pencil", title: "Edit Profile", tint: ColorTokens.primaryTealDark)
                    }
                }
                .cardStyle(padding: 0)
                
                // Log Out Action
                SecondaryButton(
                    title: "Log Out",
                    icon: "rectangle.portrait.and.arrow.right",
                    isDestructive: true
                ) {
                    showLogoutConfirmation = true
                }
                .padding(.top, SpacingTokens.xs)
                
                // App Version Footer
                VStack(spacing: 2) {
                    Text(AppConstants.appName)
                        .font(TypographyTokens.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTokens.textSecondary)
                    Text("Version \(AppConstants.appVersion)")
                        .font(TypographyTokens.caption)
                        .foregroundColor(ColorTokens.textMuted)
                }
                .padding(.top, SpacingTokens.sm)
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.bottom, SpacingTokens.xxl)
        }
        .background(ColorTokens.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .alert("Confirm Log Out", isPresented: $showLogoutConfirmation) {
            Button("Log Out", role: .destructive) {
                appState.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log out of DoseMate? Your medication schedules remain securely saved on the server.")
        }
        .task {
            await viewModel.loadProfile()
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(TypographyTokens.subheadline)
                .foregroundColor(ColorTokens.textSecondary)
            Spacer()
            Text(value)
                .font(TypographyTokens.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorTokens.textPrimary)
        }
    }
    
    private func settingsRow(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: SpacingTokens.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpacingTokens.radiusSm, style: .continuous)
                    .fill(tint.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(tint)
            }
            
            Text(title)
                .font(TypographyTokens.bodyMedium)
                .foregroundColor(ColorTokens.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ColorTokens.textMuted)
        }
        .padding(SpacingTokens.md)
        .contentShape(Rectangle())
    }
}
