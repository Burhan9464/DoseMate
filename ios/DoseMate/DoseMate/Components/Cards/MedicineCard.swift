import SwiftUI

struct MedicineCard: View {
    let medicine: MedicineSummaryDTO
    
    var body: some View {
        HStack(spacing: SpacingTokens.md) {
            // Type Icon
            ZStack {
                RoundedRectangle(cornerRadius: SpacingTokens.radiusSm, style: .continuous)
                    .fill(medicine.status == .active ? ColorTokens.primaryTealSubtle : ColorTokens.cardBorder.opacity(0.4))
                    .frame(width: 48, height: 48)
                
                Image(systemName: medicine.type.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(medicine.status == .active ? ColorTokens.primaryTeal : ColorTokens.textMuted)
            }
            
            // Info Column
            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                HStack(spacing: SpacingTokens.xs) {
                    Text(medicine.name)
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    if medicine.status == .paused {
                        Text("PAUSED")
                            .font(TypographyTokens.micro)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(ColorTokens.statusWarningSubtle)
                            .foregroundColor(ColorTokens.statusWarning)
                            .clipShape(Capsule())
                    }
                }
                
                Text(medicine.formattedDosage)
                    .font(TypographyTokens.subheadline)
                    .foregroundColor(ColorTokens.textSecondary)
                
                if let summary = medicine.scheduleSummary, !summary.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text(summary)
                            .font(TypographyTokens.caption)
                    }
                    .foregroundColor(ColorTokens.textMuted)
                    .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Stock & Chevron
            VStack(alignment: .trailing, spacing: SpacingTokens.xs) {
                if let remaining = medicine.inventoryRemaining {
                    HStack(spacing: 3) {
                        Image(systemName: medicine.isLowStock == true ? "exclamationmark.triangle.fill" : "shippingbox.fill")
                            .font(.system(size: 10))
                        Text("\(remaining) left")
                            .font(TypographyTokens.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(medicine.isLowStock == true ? ColorTokens.statusWarning : ColorTokens.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(medicine.isLowStock == true ? ColorTokens.statusWarningSubtle : ColorTokens.cardBorder.opacity(0.3))
                    .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ColorTokens.textMuted)
            }
        }
        .cardStyle(padding: SpacingTokens.md)
    }
}
