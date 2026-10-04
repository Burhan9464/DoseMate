import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: SpacingTokens.md) {
            ZStack {
                Circle()
                    .fill(ColorTokens.primaryTealSubtle)
                    .frame(width: 80, height: 80)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(ColorTokens.primaryTeal)
            }
            .padding(.bottom, SpacingTokens.xs)
            
            Text(title)
                .font(TypographyTokens.title2)
                .foregroundColor(ColorTokens.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SpacingTokens.xl)
            
            if let buttonTitle = buttonTitle, let action = action {
                Button(action: {
                    HapticService.shared.selection()
                    action()
                }) {
                    Text(buttonTitle)
                        .font(TypographyTokens.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, SpacingTokens.xl)
                        .frame(height: 44)
                        .background(ColorTokens.brandGradient)
                        .clipShape(Capsule())
                        .shadow(color: ColorTokens.primaryTeal.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                .padding(.top, SpacingTokens.sm)
            }
        }
        .padding(.vertical, SpacingTokens.xxl)
        .frame(maxWidth: .infinity)
    }
}

struct LoadingOverlay: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
            
            VStack(spacing: SpacingTokens.md) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ColorTokens.primaryTeal))
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(TypographyTokens.subheadline)
                    .foregroundColor(ColorTokens.textPrimary)
                    .fontWeight(.medium)
            }
            .padding(SpacingTokens.xl)
            .background(ColorTokens.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusLg, style: .continuous))
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        }
    }
}
