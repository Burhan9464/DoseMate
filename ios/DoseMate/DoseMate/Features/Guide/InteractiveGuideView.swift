import SwiftUI

struct InteractiveGuideView: View {
    @StateObject private var viewModel = InteractiveGuideViewModel()
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            // Dark Backdrop
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack {
                // Top Header with Step indicator & Skip
                HStack {
                    HStack(spacing: 6) {
                        ForEach(0..<viewModel.steps.count, id: \.self) { idx in
                            Capsule()
                                .fill(idx == viewModel.currentStepIndex ? ColorTokens.primaryTeal : Color.white.opacity(0.3))
                                .frame(width: idx == viewModel.currentStepIndex ? 24 : 8, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.currentStepIndex)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        HapticService.shared.selection()
                        appState.completeGuide()
                    }) {
                        Text("Skip")
                            .font(TypographyTokens.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, SpacingTokens.md)
                            .padding(.vertical, SpacingTokens.xs)
                    }
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.top, SpacingTokens.lg)
                
                Spacer()
                
                // Spotlight Card
                VStack(spacing: SpacingTokens.lg) {
                    ZStack {
                        Circle()
                            .fill(viewModel.currentStep.accentColor.opacity(0.15))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: viewModel.currentStep.iconName)
                            .font(.system(size: 44))
                            .foregroundColor(viewModel.currentStep.accentColor)
                    }
                    
                    VStack(spacing: SpacingTokens.xs) {
                        Text("STEP \(viewModel.currentStep.stepNumber) OF 5")
                            .font(TypographyTokens.caption)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.currentStep.accentColor)
                            .tracking(1)
                        
                        Text(viewModel.currentStep.title)
                            .font(TypographyTokens.title1)
                            .foregroundColor(ColorTokens.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.currentStep.description)
                            .font(TypographyTokens.body)
                            .foregroundColor(ColorTokens.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                            .padding(.horizontal, SpacingTokens.sm)
                    }
                }
                .padding(SpacingTokens.xl)
                .background(ColorTokens.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusXl, style: .continuous))
                .shadow(color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
                .padding(.horizontal, SpacingTokens.lg)
                .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                
                Spacer()
                
                // Bottom Button Bar
                HStack(spacing: SpacingTokens.md) {
                    if viewModel.currentStepIndex > 0 {
                        Button(action: {
                            HapticService.shared.selection()
                            viewModel.previousStep()
                        }) {
                            Text("Back")
                                .font(TypographyTokens.headline)
                                .foregroundColor(.white)
                                .frame(width: 80, height: SpacingTokens.buttonHeight)
                                .background(Color.white.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd))
                        }
                    }
                    
                    PrimaryButton(
                        title: viewModel.isLastStep ? "Let's Go!" : "Next",
                        icon: viewModel.isLastStep ? "checkmark" : "arrow.right"
                    ) {
                        if viewModel.isLastStep {
                            HapticService.shared.success()
                            appState.completeGuide()
                        } else {
                            viewModel.nextStep()
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xl)
            }
        }
    }
}
