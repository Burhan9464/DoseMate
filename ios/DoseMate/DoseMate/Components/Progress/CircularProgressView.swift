import SwiftUI

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let takenDoses: Int
    let totalDoses: Int
    let skippedDoses: Int
    
    var isAllDone: Bool {
        totalDoses > 0 && takenDoses >= totalDoses
    }
    
    var body: some View {
        HStack(spacing: SpacingTokens.lg) {
            // Circular Ring
            ZStack {
                // Background Track
                Circle()
                    .stroke(ColorTokens.cardBorder.opacity(0.6), lineWidth: 10)
                    .frame(width: 90, height: 90)
                
                // Progress Arc
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(
                        isAllDone
                            ? LinearGradient(colors: [ColorTokens.statusTaken, ColorTokens.primaryTealLight], startPoint: .top, endPoint: .bottom)
                            : ColorTokens.brandGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 90, height: 90)
                    .animation(.easeOut(duration: 0.6), value: progress)
                
                // Center Percentage or Icon
                VStack(spacing: 2) {
                    if isAllDone {
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(ColorTokens.statusTaken)
                    } else if totalDoses == 0 {
                        Image(systemName: "pill.fill")
                            .font(.system(size: 20))
                            .foregroundColor(ColorTokens.textMuted)
                    } else {
                        Text("\(Int(progress * 100))%")
                            .font(TypographyTokens.title2)
                            .foregroundColor(ColorTokens.textPrimary)
                    }
                }
            }
            
            // Textual Breakdown
            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                Text("Daily Adherence")
                    .font(TypographyTokens.caption)
                    .foregroundColor(ColorTokens.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                if totalDoses == 0 {
                    Text("No doses scheduled")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.textPrimary)
                    Text("Enjoy your rest day")
                        .font(TypographyTokens.subheadline)
                        .foregroundColor(ColorTokens.textSecondary)
                } else if isAllDone {
                    Text("All Completed!")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.statusTaken)
                    Text("\(takenDoses) of \(totalDoses) taken today")
                        .font(TypographyTokens.subheadline)
                        .foregroundColor(ColorTokens.textSecondary)
                } else {
                    Text("\(takenDoses) of \(totalDoses) doses taken")
                        .font(TypographyTokens.headline)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    if skippedDoses > 0 {
                        Text("\(skippedDoses) skipped")
                            .font(TypographyTokens.caption)
                            .foregroundColor(ColorTokens.statusSkipped)
                    } else {
                        Text("\(totalDoses - takenDoses) remaining today")
                            .font(TypographyTokens.subheadline)
                            .foregroundColor(ColorTokens.textSecondary)
                    }
                }
            }
            
            Spacer()
        }
        .cardStyle(padding: SpacingTokens.md)
    }
}
