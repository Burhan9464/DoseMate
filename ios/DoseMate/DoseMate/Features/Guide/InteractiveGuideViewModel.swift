import SwiftUI

struct GuideStep: Identifiable {
    let id: Int
    let stepNumber: Int
    let title: String
    let description: String
    let iconName: String
    let accentColor: Color
}

@MainActor
final class InteractiveGuideViewModel: ObservableObject {
    @Published var currentStepIndex: Int = 0
    
    let steps: [GuideStep] = [
        GuideStep(
            id: 0,
            stepNumber: 1,
            title: "Your Daily Dashboard",
            description: "View your real-time daily adherence ring, upcoming doses, and what needs immediate attention at a glance.",
            iconName: "chart.pie.fill",
            accentColor: ColorTokens.primaryTeal
        ),
        GuideStep(
            id: 1,
            stepNumber: 2,
            title: "Organize Medications",
            description: "Easily add your tablets, capsules, drops, or syrups with custom daily times, specific weekdays, and treatment periods.",
            iconName: "pills.fill",
            accentColor: ColorTokens.secondarySky
        ),
        GuideStep(
            id: 2,
            stepNumber: 3,
            title: "Drag-the-Pill Confirmation",
            description: "DoseMate's signature interaction: slide the pill handle across to record an ingestion with satisfying tactile haptics.",
            iconName: "hand.draw.fill",
            accentColor: ColorTokens.statusTaken
        ),
        GuideStep(
            id: 3,
            stepNumber: 4,
            title: "Smart Inventory Tracking",
            description: "Every taken dose automatically decrements your remaining stock. Set thresholds to get warned before pills run out.",
            iconName: "shippingbox.fill",
            accentColor: ColorTokens.statusWarning
        ),
        GuideStep(
            id: 4,
            stepNumber: 5,
            title: "Medication History",
            description: "Review complete date-grouped logs of taken, skipped, and missed doses. Filter by status or search by medicine name.",
            iconName: "clock.arrow.circlepath",
            accentColor: ColorTokens.primaryTealDark
        )
    ]
    
    var currentStep: GuideStep {
        steps[currentStepIndex]
    }
    
    var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }
    
    func nextStep() {
        if !isLastStep {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStepIndex += 1
            }
        }
    }
    
    func previousStep() {
        if currentStepIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStepIndex -= 1
            }
        }
    }
}
