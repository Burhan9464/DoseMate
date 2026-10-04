import SwiftUI

struct AttentionCard: View {
    let item: AttentionItemDTO
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: SpacingTokens.md) {
                ZStack {
                    Circle()
                        .fill(ColorTokens.statusWarningSubtle)
                        .frame(width: 40, height: 40)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(ColorTokens.statusWarning)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.type == "LOW_INVENTORY" ? "Low Stock Alert" : "Attention Required")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.textPrimary)
                    Text(item.message)
                        .font(TypographyTokens.subheadline)
                        .foregroundColor(ColorTokens.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(ColorTokens.textMuted)
                }
            }
            .cardStyle(padding: SpacingTokens.md)
            .overlay(
                RoundedRectangle(cornerRadius: SpacingTokens.radiusLg, style: .continuous)
                    .stroke(ColorTokens.statusWarning.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
