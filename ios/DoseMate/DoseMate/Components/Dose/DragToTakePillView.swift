import SwiftUI

/// Signature Drag-the-Pill interaction for confirming medication ingestion.
struct DragToTakePillView: View {
    var isSubmitting: Bool
    let onComplete: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isThresholdPassed: Bool = false
    @State private var trackWidth: CGFloat = 0
    
    private let handleSize: CGFloat = SpacingTokens.pillHandleSize
    private let trackHeight: CGFloat = SpacingTokens.pillTrackHeight
    private let completionThresholdPercentage: CGFloat = 0.72
    
    var body: some View {
        GeometryReader { geometry in
            let maxDrag = max(0, geometry.size.width - handleSize - 8)
            
            ZStack(alignment: .leading) {
                // Background Track
                RoundedRectangle(cornerRadius: SpacingTokens.radiusPill, style: .continuous)
                    .fill(ColorTokens.primaryTealSubtle.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpacingTokens.radiusPill, style: .continuous)
                            .stroke(ColorTokens.primaryTeal.opacity(0.2), lineWidth: 1.5)
                    )
                
                // Active Completed Track Fill
                RoundedRectangle(cornerRadius: SpacingTokens.radiusPill, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ColorTokens.primaryTeal.opacity(0.3), ColorTokens.primaryTealLight.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(handleSize, dragOffset + handleSize + 4))
                
                // Track Label / Instruction
                HStack {
                    Spacer()
                    if !isSubmitting {
                        HStack(spacing: SpacingTokens.xs) {
                            Text("Slide to record dose")
                                .font(TypographyTokens.headline)
                                .foregroundColor(ColorTokens.primaryTealDark)
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ColorTokens.primaryTeal)
                        }
                        .opacity(Double(1.0 - (dragOffset / (maxDrag > 0 ? maxDrag : 1))))
                    } else {
                        Text("Recording dose...")
                            .font(TypographyTokens.headline)
                            .foregroundColor(ColorTokens.primaryTealDark)
                    }
                    Spacer()
                }
                .padding(.leading, handleSize / 2)
                
                // Draggable Pill Handle
                ZStack {
                    Circle()
                        .fill(ColorTokens.brandGradient)
                        .shadow(color: ColorTokens.primaryTeal.opacity(0.4), radius: 6, x: 2, y: 2)
                    
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: isThresholdPassed ? "checkmark" : "pills.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isThresholdPassed ? 0 : Double(dragOffset * 0.15)))
                    }
                }
                .frame(width: handleSize, height: handleSize)
                .padding(.leading, 4)
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            guard !isSubmitting else { return }
                            let proposed = gesture.translation.width
                            if proposed > 0 {
                                dragOffset = min(proposed, maxDrag)
                                
                                let passed = dragOffset >= (maxDrag * completionThresholdPercentage)
                                if passed != isThresholdPassed {
                                    isThresholdPassed = passed
                                    HapticService.shared.impact(style: passed ? .medium : .light)
                                }
                            }
                        }
                        .onEnded { gesture in
                            guard !isSubmitting else { return }
                            let passed = dragOffset >= (maxDrag * completionThresholdPercentage)
                            if passed {
                                // Snap to finish, trigger haptic and invoke callback
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                    dragOffset = maxDrag
                                }
                                HapticService.shared.success()
                                onComplete()
                            } else {
                                // Spring back to start
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    dragOffset = 0
                                    isThresholdPassed = false
                                }
                            }
                        }
                )
            }
            .frame(height: trackHeight)
            .onAppear {
                trackWidth = geometry.size.width
            }
            .onChange(of: isSubmitting) { submitting in
                if !submitting && dragOffset >= (maxDrag * completionThresholdPercentage) {
                    // Reset handle after completion
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        dragOffset = 0
                        isThresholdPassed = false
                    }
                }
            }
        }
        .frame(height: trackHeight)
    }
}
