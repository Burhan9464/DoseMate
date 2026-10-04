import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()
            
            VStack(spacing: SpacingTokens.lg) {
                // Branded App Logo
                ZStack {
                    Circle()
                        .fill(ColorTokens.brandGradient)
                        .frame(width: 96, height: 96)
                        .shadow(color: ColorTokens.primaryTeal.opacity(0.35), radius: 14, x: 0, y: 6)
                    
                    Image(systemName: "pills.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(viewModel.isAnimating ? 0 : -25))
                        .scaleEffect(viewModel.isAnimating ? 1.0 : 0.8)
                }
                
                VStack(spacing: SpacingTokens.xs) {
                    Text(AppConstants.appName)
                        .font(TypographyTokens.largeTitle)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Text("Calm, Consistent Medicine Management")
                        .font(TypographyTokens.subheadline)
                        .foregroundColor(ColorTokens.textSecondary)
                }
                .opacity(viewModel.isAnimating ? 1.0 : 0.0)
                .offset(y: viewModel.isAnimating ? 0 : 10)
            }
        }
        .task {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                viewModel.isAnimating = true
            }
            await viewModel.startInitialFlow(appState: appState)
        }
    }
}
