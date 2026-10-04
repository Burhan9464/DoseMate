import SwiftUI

/// Semantic typography tokens mapping to Apple's Human Interface Guidelines.
enum TypographyTokens {
    static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 26, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 18, weight: .semibold, design: .default)
    
    static let headline = Font.system(size: 16, weight: .semibold, design: .default)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .medium, design: .default)
    
    static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let micro = Font.system(size: 10, weight: .medium, design: .default)
}
