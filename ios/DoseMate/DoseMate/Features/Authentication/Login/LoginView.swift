import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var appState: AppState
    let onNavigateToRegister: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: SpacingTokens.xl) {
                // Header Branding
                VStack(spacing: SpacingTokens.sm) {
                    ZStack {
                        Circle()
                            .fill(ColorTokens.brandGradient)
                            .frame(width: 72, height: 72)
                            .shadow(color: ColorTokens.primaryTeal.opacity(0.3), radius: 10, x: 0, y: 4)
                        Image(systemName: "pills.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, SpacingTokens.lg)
                    
                    Text("Welcome Back")
                        .font(TypographyTokens.title1)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Text("Sign in to sync your medication schedules")
                        .font(TypographyTokens.subheadline)
                        .foregroundColor(ColorTokens.textSecondary)
                }
                
                // Form Fields
                VStack(spacing: SpacingTokens.md) {
                    CustomTextField(
                        title: "Email Address",
                        placeholder: "jane@example.com",
                        text: $viewModel.email,
                        icon: "envelope.fill",
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        errorMessage: viewModel.emailError
                    )
                    
                    CustomTextField(
                        title: "Password",
                        placeholder: "••••••••",
                        text: $viewModel.password,
                        icon: "lock.fill",
                        isSecure: true,
                        errorMessage: viewModel.passwordError
                    )
                    
                    if let error = viewModel.errorMessage {
                        HStack(spacing: SpacingTokens.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(ColorTokens.statusMissed)
                            Text(error)
                                .font(TypographyTokens.footnote)
                                .foregroundColor(ColorTokens.statusMissed)
                        }
                        .padding(SpacingTokens.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ColorTokens.statusMissedSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusSm))
                    }
                }
                .cardStyle(padding: SpacingTokens.lg)
                
                // Submit Button
                VStack(spacing: SpacingTokens.md) {
                    PrimaryButton(
                        title: "Sign In",
                        icon: "arrow.right",
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            _ = await viewModel.login(appState: appState)
                        }
                    }
                    
                    // Link to Register
                    HStack {
                        Text("Don't have an account?")
                            .font(TypographyTokens.subheadline)
                            .foregroundColor(ColorTokens.textSecondary)
                        
                        Button(action: {
                            HapticService.shared.selection()
                            onNavigateToRegister()
                        }) {
                            Text("Create Account")
                                .font(TypographyTokens.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(ColorTokens.primaryTeal)
                        }
                    }
                    .padding(.top, SpacingTokens.xs)
                }
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.bottom, SpacingTokens.xxl)
        }
        .background(ColorTokens.background.ignoresSafeArea())
        .onTapGesture {
            hideKeyboard()
        }
    }
}
