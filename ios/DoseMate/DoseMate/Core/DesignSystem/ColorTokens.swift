import SwiftUI

/// Semantic color design tokens for DoseMate following the healthcare visual language.
enum ColorTokens {
    // MARK: - Brand Palette
    static let primaryTeal = Color(hex: "#0D9488")
    static let primaryTealDark = Color(hex: "#0F766E")
    static let primaryTealLight = Color(hex: "#14B8A6")
    static let primaryTealSubtle = Color(hex: "#CCFBF1")
    
    static let secondarySky = Color(hex: "#0284C7")
    static let secondarySkyLight = Color(hex: "#38BDF8")
    static let secondarySkySubtle = Color(hex: "#E0F2FE")
    
    // MARK: - Status Indicators
    static let statusTaken = Color(hex: "#10B981")       // Emerald green
    static let statusTakenSubtle = Color(hex: "#D1FAE5")
    
    static let statusDue = Color(hex: "#0D9488")         // Brand teal
    static let statusDueSubtle = Color(hex: "#CCFBF1")
    
    static let statusSkipped = Color(hex: "#64748B")     // Neutral slate
    static let statusSkippedSubtle = Color(hex: "#F1F5F9")
    
    static let statusMissed = Color(hex: "#EF4444")      // Rose red
    static let statusMissedSubtle = Color(hex: "#FEE2E2")
    
    static let statusWarning = Color(hex: "#F59E0B")     // Amber gold (low inventory)
    static let statusWarningSubtle = Color(hex: "#FEF3C7")
    
    // MARK: - Gradients
    static let brandGradient = LinearGradient(
        colors: [primaryTeal, primaryTealLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color(hex: "#0D9488").opacity(0.08), Color(hex: "#0284C7").opacity(0.03)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let pillTrackGradient = LinearGradient(
        colors: [Color(hex: "#F1F5F9"), Color(hex: "#E2E8F0")],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Neutral Adaptive Palette
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1) // #0F172A
                : UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1) // #F8FAFC
        })
    }
    
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1) // #1E293B
                : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1) // #FFFFFF
        })
    }
    
    static var cardBorder: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 51/255, green: 65/255, blue: 85/255, alpha: 1) // #334155
                : UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 1) // #E2E8F0
        })
    }
    
    static var textPrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1) // #F8FAFC
                : UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1) // #0F172A
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1) // #94A3B8
                : UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1) // #64748B
        })
    }
    
    static var textMuted: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1) // #64748B
                : UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1) // #94A3B8
        })
    }
}
