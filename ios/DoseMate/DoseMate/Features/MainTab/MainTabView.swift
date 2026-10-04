import SwiftUI

enum TabItem: Int, CaseIterable {
    case dashboard = 0
    case medicines = 1
    case history = 2
    case profile = 3
    
    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .medicines: return "Medicines"
        case .history: return "History"
        case .profile: return "Profile"
        }
    }
    
    var iconName: String {
        switch self {
        case .dashboard: return "house.fill"
        case .medicines: return "pills.fill"
        case .history: return "clock.arrow.circlepath"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: TabItem = .dashboard
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(onNavigateToMedicines: {
                selectedTab = .medicines
            })
            .tabItem {
                Label(TabItem.dashboard.title, systemImage: TabItem.dashboard.iconName)
            }
            .tag(TabItem.dashboard)
            
            NavigationStack {
                MedicineListView()
            }
            .tabItem {
                Label(TabItem.medicines.title, systemImage: TabItem.medicines.iconName)
            }
            .tag(TabItem.medicines)
            
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label(TabItem.history.title, systemImage: TabItem.history.iconName)
            }
            .tag(TabItem.history)
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(TabItem.profile.title, systemImage: TabItem.profile.iconName)
            }
            .tag(TabItem.profile)
        }
        .tint(ColorTokens.primaryTeal)
        .fullScreenCover(isPresented: $appState.shouldShowGuide) {
            InteractiveGuideView()
        }
    }
}
