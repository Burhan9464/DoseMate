import SwiftUI

enum ToastType {
    case info
    case success
    case error
    case undo(action: () -> Void)
}

struct ToastBanner: View {
    let message: String
    let type: ToastType
    var onDismiss: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: SpacingTokens.md) {
            switch type {
            case .info:
                Image(systemName: "info.circle.fill")
                    .foregroundColor(ColorTokens.secondarySky)
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ColorTokens.statusTaken)
            case .error:
                Image(systemName: "exclamationmark.octagon.fill")
                    .foregroundColor(ColorTokens.statusMissed)
            case .undo:
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundColor(ColorTokens.primaryTealLight)
            }
            
            Text(message)
                .font(TypographyTokens.footnote)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Spacer()
            
            if case .undo(let action) = type {
                Button(action: {
                    HapticService.shared.selection()
                    action()
                }) {
                    Text("UNDO")
                        .font(TypographyTokens.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTokens.primaryTealLight)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            } else if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, SpacingTokens.md)
        .padding(.vertical, SpacingTokens.sm + 4)
        .background(Color(hex: "#1E293B").opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd, style: .continuous))
        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 5)
        .padding(.horizontal, SpacingTokens.md)
    }
}
