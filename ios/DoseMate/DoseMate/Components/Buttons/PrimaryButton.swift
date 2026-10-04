import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            guard isEnabled && !isLoading else { return }
            HapticService.shared.selection()
            action()
        }) {
            HStack(spacing: SpacingTokens.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(TypographyTokens.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: SpacingTokens.buttonHeight)
            .background(
                isEnabled
                    ? ColorTokens.brandGradient
                    : LinearGradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd, style: .continuous))
            .shadow(color: isEnabled ? ColorTokens.primaryTeal.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .disabled(!isEnabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
