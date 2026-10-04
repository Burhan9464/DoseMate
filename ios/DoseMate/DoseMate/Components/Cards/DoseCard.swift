import SwiftUI

struct DoseCard: View {
    let dose: DoseRecordDTO
    var isCurrentDue: Bool = false
    var onSkip: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpacingTokens.md) {
            HStack(alignment: .top) {
                // Medicine Icon & Details
                HStack(spacing: SpacingTokens.sm) {
                    ZStack {
                        Circle()
                            .fill(dose.status.subtleBackgroundColor)
                            .frame(width: 44, height: 44)
                        Image(systemName: dose.type?.iconName ?? "pills.fill")
                            .font(.system(size: 20))
                            .foregroundColor(dose.status.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dose.medicineName)
                            .font(TypographyTokens.headline)
                            .foregroundColor(ColorTokens.textPrimary)
                        Text(dose.dosage)
                            .font(TypographyTokens.subheadline)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
                
                Spacer()
                
                // Status / Time Pill
                VStack(alignment: .trailing, spacing: SpacingTokens.xs) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(dose.formattedTime)
                            .font(TypographyTokens.caption)
                    }
                    .foregroundColor(ColorTokens.textSecondary)
                    
                    // Status Badge
                    Text(dose.status.displayName)
                        .font(TypographyTokens.micro)
                        .fontWeight(.semibold)
                        .padding(.horizontal, SpacingTokens.sm)
                        .padding(.vertical, 3)
                        .background(dose.status.subtleBackgroundColor)
                        .foregroundColor(dose.status.color)
                        .clipShape(Capsule())
                }
            }
            
            // If Due and pending, offer Skip action button
            if isCurrentDue && dose.status == .pending, let onSkip = onSkip {
                Divider()
                    .padding(.vertical, 2)
                
                HStack {
                    Spacer()
                    Button(action: {
                        HapticService.shared.selection()
                        onSkip()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 12))
                            Text("Skip Dose")
                                .font(TypographyTokens.footnote)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(ColorTokens.statusSkipped)
                        .padding(.horizontal, SpacingTokens.md)
                        .padding(.vertical, 6)
                        .background(ColorTokens.statusSkippedSubtle)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .cardStyle(padding: SpacingTokens.md)
    }
}
