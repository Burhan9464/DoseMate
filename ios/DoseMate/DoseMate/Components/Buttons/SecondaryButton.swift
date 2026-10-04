import SwiftUI

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    var isDestructive: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            HapticService.shared.selection()
            action()
        }) {
            HStack(spacing: SpacingTokens.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(TypographyTokens.headline)
            }
            .foregroundColor(isDestructive ? ColorTokens.statusMissed : ColorTokens.primaryTeal)
            .frame(maxWidth: .infinity)
            .frame(height: SpacingTokens.buttonHeight)
            .background(
                isDestructive
                    ? ColorTokens.statusMissedSubtle
                    : ColorTokens.primaryTealSubtle
            )
            .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpacingTokens.radiusMd, style: .continuous)
                    .stroke(
                        isDestructive ? ColorTokens.statusMissed.opacity(0.3) : ColorTokens.primaryTeal.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .disabled(!isEnabled)
    }
}
