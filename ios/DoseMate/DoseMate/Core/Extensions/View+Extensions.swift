import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

extension View {
    /// Applies a clean card style with adaptive background, subtle border, and soft shadow.
    func cardStyle(
        padding: CGFloat = SpacingTokens.md,
        cornerRadius: CGFloat = SpacingTokens.radiusLg
    ) -> some View {
        self
            .padding(padding)
            .background(ColorTokens.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(ColorTokens.cardBorder.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    /// Hides keyboard on tap or gesture.
    func hideKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
    
    /// Conditionally applies a view transformation.
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
