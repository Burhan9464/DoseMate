import SwiftUI

enum AppDestination: Hashable {
    case login
    case register
    case registrationSuccess
    case medicineDetails(medicineId: Int64)
    case addMedicine
    case editMedicine(medicineId: Int64)
    case notificationsSettings
    case editProfile
    case settings
}

final class AppRouter: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    func navigate(to destination: AppDestination) {
        navigationPath.append(destination)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
