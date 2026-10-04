import SwiftUI

struct MedicineListView: View {
    @StateObject private var viewModel = MedicineListViewModel()
    @State private var isShowingAddModal: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpacingTokens.lg) {
                // Search Input
                HStack(spacing: SpacingTokens.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ColorTokens.textMuted)
                    TextField("Search medicines or dosage...", text: $viewModel.searchText)
                        .font(TypographyTokens.body)
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ColorTokens.textMuted)
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.md)
                .frame(height: 44)
                .background(ColorTokens.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd))
                .overlay(
                    RoundedRectangle(cornerRadius: SpacingTokens.radiusMd)
                        .stroke(ColorTokens.cardBorder, lineWidth: 1)
                )
                .padding(.top, SpacingTokens.xs)
                
                // Active Section
                if !viewModel.activeMedicines.isEmpty {
                    VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                        Text("Active Medications (\(viewModel.activeMedicines.count))")
                            .font(TypographyTokens.headline)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        ForEach(viewModel.activeMedicines) { medicine in
                            NavigationLink(destination: MedicineDetailsView(medicineId: medicine.id)) {
                                MedicineCard(medicine: medicine)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // Paused Section
                if !viewModel.pausedMedicines.isEmpty {
                    VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                        Text("Paused (\(viewModel.pausedMedicines.count))")
                            .font(TypographyTokens.headline)
                            .foregroundColor(ColorTokens.textSecondary)
                        
                        ForEach(viewModel.pausedMedicines) { medicine in
                            NavigationLink(destination: MedicineDetailsView(medicineId: medicine.id)) {
                                MedicineCard(medicine: medicine)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, SpacingTokens.sm)
                }
                
                // Empty State
                if viewModel.medicines.isEmpty && !viewModel.isLoading {
                    EmptyStateView(
                        icon: "pills.fill",
                        title: "No Medications Added",
                        message: "Add your medications with their schedules to begin receiving reminders and tracking inventory.",
                        buttonTitle: "Add Medication"
                    ) {
                        isShowingAddModal = true
                    }
                }
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.bottom, SpacingTokens.xxl)
        }
        .background(ColorTokens.background.ignoresSafeArea())
        .navigationTitle("Medicines")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    HapticService.shared.selection()
                    isShowingAddModal = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(ColorTokens.primaryTeal)
                }
            }
        }
        .sheet(isPresented: $isShowingAddModal) {
            AddMedicineView {
                Task {
                    await viewModel.loadMedicines()
                }
            }
        }
        .refreshable {
            await viewModel.loadMedicines()
        }
        .task {
            await viewModel.loadMedicines()
        }
    }
}
