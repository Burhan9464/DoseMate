import SwiftUI

/// Layout spacing and corner radius tokens based on a 4pt/8pt grid.
enum SpacingTokens {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    
    // MARK: - Corner Radii
    static let radiusSm: CGFloat = 8
    static let radiusMd: CGFloat = 14
    static let radiusLg: CGFloat = 20
    static let radiusXl: CGFloat = 28
    static let radiusPill: CGFloat = 999
    
    // MARK: - Component Dimensions
    static let buttonHeight: CGFloat = 52
    static let inputHeight: CGFloat = 50
    static let pillTrackHeight: CGFloat = 64
    static let pillHandleSize: CGFloat = 52
}
