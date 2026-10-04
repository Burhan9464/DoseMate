import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var dashboardData: DashboardDTO? = nil
    @Published var isLoading: Bool = false
    @Published var isTakingDose: Bool = false
    @Published var errorMessage: String? = nil
    
    // Undo Snackbar State
    @Published var lastSkippedDoseId: Int64? = nil
    @Published var showUndoToast: Bool = false
    @Published var undoToastMessage: String = ""
    
    private let dashboardRepository: DashboardRepositoryProtocol
    private let doseRepository: DoseRepositoryProtocol
    
    init(
        dashboardRepository: DashboardRepositoryProtocol = DashboardRepository(),
        doseRepository: DoseRepositoryProtocol = DoseRepository()
    ) {
        self.dashboardRepository = dashboardRepository
        self.doseRepository = doseRepository
    }
    
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await dashboardRepository.getDashboard()
            self.dashboardData = data
            self.isLoading = false
        } catch let apiError as APIError {
            self.isLoading = false
            self.errorMessage = apiError.errorDescription
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// Executes the signature Drag-the-Pill take transaction.
    func takeCurrentDose(doseId: Int64) async {
        guard !isTakingDose else { return }
        isTakingDose = true
        errorMessage = nil
        
        do {
            _ = try await doseRepository.markTaken(id: doseId)
            HapticService.shared.success()
            
            // Reload fresh dashboard state from backend
            await loadDashboard()
            isTakingDose = false
        } catch let apiError as APIError {
            isTakingDose = false
            HapticService.shared.error()
            self.errorMessage = apiError.errorDescription
        } catch {
            isTakingDose = false
            HapticService.shared.error()
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// Skips the currently due dose and offers an Undo window.
    func skipCurrentDose(doseId: Int64) async {
        errorMessage = nil
        do {
            _ = try await doseRepository.markSkipped(id: doseId)
            lastSkippedDoseId = doseId
            undoToastMessage = "Dose marked as skipped."
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showUndoToast = true
            }
            
            // Auto dismiss toast after 8 seconds
            Task {
                try? await Task.sleep(nanoseconds: 8_000_000_000)
                withAnimation {
                    self.showUndoToast = false
                }
            }
            
            await loadDashboard()
        } catch let apiError as APIError {
            self.errorMessage = apiError.errorDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// Reverts the skip action if within the allowed window.
    func undoLastSkip() async {
        guard let doseId = lastSkippedDoseId else { return }
        withAnimation {
            showUndoToast = false
        }
        
        do {
            _ = try await doseRepository.undoSkip(id: doseId)
            HapticService.shared.success()
            lastSkippedDoseId = nil
            await loadDashboard()
        } catch let apiError as APIError {
            self.errorMessage = apiError.errorDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
