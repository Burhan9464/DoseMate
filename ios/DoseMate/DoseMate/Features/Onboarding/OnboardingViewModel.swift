import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let iconName: String
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Never Miss a Dose",
            subtitle: "Organize your medications, vitamins, and supplements in one calm, reliable sanctuary.",
            iconName: "pills.fill"
        ),
        OnboardingPage(
            id: 1,
            title: "Smart Reminders & Tracking",
            subtitle: "Receive timely local notifications and record doses with our signature Drag-the-Pill gesture.",
            iconName: "bell.badge.fill"
        ),
        OnboardingPage(
            id: 2,
            title: "Monitor Inventory & Progress",
            subtitle: "Keep track of remaining pill counts, receive low-stock alerts, and celebrate your adherence.",
            iconName: "chart.line.uptrend.xyaxis.circle.fill"
        )
    ]
    
    var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }
    
    func advancePage() {
        if !isLastPage {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPageIndex += 1
            }
        }
    }
}
