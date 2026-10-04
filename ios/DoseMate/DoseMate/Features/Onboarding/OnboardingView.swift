import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var appState: AppState
    let onFinish: () -> Void
    
    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()
            
            VStack {
                // Top Bar with Skip Button
                HStack {
                    Spacer()
                    Button(action: {
                        HapticService.shared.selection()
                        appState.completeOnboarding()
                        onFinish()
                    }) {
                        Text("Skip")
                            .font(TypographyTokens.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(ColorTokens.textSecondary)
                            .padding(.horizontal, SpacingTokens.md)
                            .padding(.vertical, SpacingTokens.sm)
                    }
                }
                .padding(.horizontal, SpacingTokens.md)
                
                // Swiping Page Content
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(viewModel.pages) { page in
                        VStack(spacing: SpacingTokens.xl) {
                            Spacer()
                            
                            // Visual Hero Icon
                            ZStack {
                                Circle()
                                    .fill(ColorTokens.primaryTealSubtle)
                                    .frame(width: 140, height: 140)
                                    .shadow(color: ColorTokens.primaryTeal.opacity(0.15), radius: 20, x: 0, y: 10)
                                
                                Image(systemName: page.iconName)
                                    .font(.system(size: 60))
                                    .foregroundColor(ColorTokens.primaryTeal)
                            }
                            
                            VStack(spacing: SpacingTokens.sm) {
                                Text(page.title)
                                    .font(TypographyTokens.title1)
                                    .foregroundColor(ColorTokens.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text(page.subtitle)
                                    .font(TypographyTokens.body)
                                    .foregroundColor(ColorTokens.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, SpacingTokens.xl)
                                    .lineSpacing(3)
                            }
                            
                            Spacer()
                        }
                        .tag(page.id)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Bottom Action Buttons
                VStack(spacing: SpacingTokens.md) {
                    if viewModel.isLastPage {
                        PrimaryButton(title: "Get Started", icon: "arrow.right") {
                            appState.completeOnboarding()
                            onFinish()
                        }
                    } else {
                        PrimaryButton(title: "Continue", icon: "chevron.right") {
                            viewModel.advancePage()
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xl)
            }
        }
    }
}
