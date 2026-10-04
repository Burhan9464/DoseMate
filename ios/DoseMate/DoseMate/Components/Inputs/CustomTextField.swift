import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var errorMessage: String? = nil
    
    @State private var isShowingPassword: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
            Text(title)
                .font(TypographyTokens.subheadline)
                .foregroundColor(ColorTokens.textSecondary)
                .fontWeight(.medium)
            
            HStack(spacing: SpacingTokens.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isFocused ? ColorTokens.primaryTeal : ColorTokens.textMuted)
                        .font(.system(size: 16))
                        .frame(width: 20)
                }
                
                if isSecure && !isShowingPassword {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                        .font(TypographyTokens.body)
                        .textInputAutocapitalization(autocapitalization)
                        .disableAutocorrection(true)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .font(TypographyTokens.body)
                        .keyboardType(keyboardType)
                        .textInputAutocapitalization(autocapitalization)
                        .disableAutocorrection(true)
                }
                
                if isSecure {
                    Button(action: {
                        isShowingPassword.toggle()
                        HapticService.shared.selection()
                    }) {
                        Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(ColorTokens.textMuted)
                            .font(.system(size: 15))
                    }
                }
            }
            .padding(.horizontal, SpacingTokens.md)
            .frame(height: SpacingTokens.inputHeight)
            .background(ColorTokens.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpacingTokens.radiusMd, style: .continuous)
                    .stroke(
                        errorMessage != nil
                            ? ColorTokens.statusMissed
                            : (isFocused ? ColorTokens.primaryTeal : ColorTokens.cardBorder),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            
            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(TypographyTokens.caption)
                }
                .foregroundColor(ColorTokens.statusMissed)
                .padding(.leading, SpacingTokens.xs)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: errorMessage)
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
