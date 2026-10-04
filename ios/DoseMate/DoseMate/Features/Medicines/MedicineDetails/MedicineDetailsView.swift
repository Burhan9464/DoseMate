import SwiftUI

struct MedicineDetailsView: View {
    @StateObject private var viewModel: MedicineDetailsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingEditModal: Bool = false
    
    init(medicineId: Int64) {
        _viewModel = StateObject(wrappedValue: MedicineDetailsViewModel(medicineId: medicineId))
    }
    
    var body: some View {
        ScrollView {
            if let medicine = viewModel.medicine {
                VStack(alignment: .leading, spacing: SpacingTokens.lg) {
                    // Hero Card
                    HStack(spacing: SpacingTokens.md) {
                        ZStack {
                            Circle()
                                .fill(ColorTokens.primaryTealSubtle)
                                .frame(width: 64, height: 64)
                            Image(systemName: medicine.type.iconName)
                                .font(.system(size: 28))
                                .foregroundColor(ColorTokens.primaryTeal)
                        }
                        
                        VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                            HStack {
                                Text(medicine.name)
                                    .font(TypographyTokens.title2)
                                    .foregroundColor(ColorTokens.textPrimary)
                                
                                Text(medicine.status.displayName.uppercased())
                                    .font(TypographyTokens.micro)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(medicine.status == .active ? ColorTokens.statusTakenSubtle : ColorTokens.statusWarningSubtle)
                                    .foregroundColor(medicine.status == .active ? ColorTokens.statusTaken : ColorTokens.statusWarning)
                                    .clipShape(Capsule())
                            }
                            
                            Text("\(medicine.formattedDosage) • \(medicine.type.displayName)")
                                .font(TypographyTokens.subheadline)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .cardStyle(padding: SpacingTokens.md)
                    
                    // Instructions Card (if provided)
                    if let instructions = medicine.instructions, !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                            Text("Instructions")
                                .font(TypographyTokens.caption)
                                .foregroundColor(ColorTokens.textSecondary)
                                .textCase(.uppercase)
                            
                            Text(instructions)
                                .font(TypographyTokens.body)
                                .foregroundColor(ColorTokens.textPrimary)
                        }
                        .cardStyle(padding: SpacingTokens.md)
                    }
                    
                    // Schedule Overview Card
                    if let schedule = medicine.schedule {
                        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                            Text("Medication Schedule")
                                .font(TypographyTokens.headline)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            Divider()
                            
                            HStack {
                                Text("Frequency")
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textSecondary)
                                Spacer()
                                Text(schedule.frequencyMode.displayName)
                                    .font(TypographyTokens.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                            
                            HStack {
                                Text("Scheduled Times")
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textSecondary)
                                Spacer()
                                Text(schedule.times.map { $0.formattedTimeString }.joined(separator: ", "))
                                    .font(TypographyTokens.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(ColorTokens.primaryTeal)
                            }
                            
                            HStack {
                                Text("Active Days")
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textSecondary)
                                Spacer()
                                Text(schedule.days.map { $0.shortName }.joined(separator: ", "))
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                            
                            HStack {
                                Text("Treatment Period")
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textSecondary)
                                Spacer()
                                Text(medicine.ongoing ? "Ongoing" : "\(medicine.startDate) to \(medicine.endDate ?? "")")
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textPrimary)
                            }
                        }
                        .cardStyle(padding: SpacingTokens.md)
                    }
                    
                    // Inventory Management Card
                    if let inventory = medicine.inventory {
                        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                            HStack {
                                Text("Inventory Status")
                                    .font(TypographyTokens.headline)
                                    .foregroundColor(ColorTokens.textPrimary)
                                Spacer()
                                if inventory.isLowStock == true {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                        Text("Low Stock")
                                    }
                                    .font(TypographyTokens.caption)
                                    .foregroundColor(ColorTokens.statusWarning)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(ColorTokens.statusWarningSubtle)
                                    .clipShape(Capsule())
                                }
                            }
                            
                            Divider()
                            
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(inventory.quantity)")
                                        .font(TypographyTokens.largeTitle)
                                        .foregroundColor(inventory.isLowStock == true ? ColorTokens.statusWarning : ColorTokens.textPrimary)
                                    Text("\(inventory.unit) remaining (Alert at ≤ \(inventory.lowStockThreshold))")
                                        .font(TypographyTokens.subheadline)
                                        .foregroundColor(ColorTokens.textSecondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: SpacingTokens.sm) {
                                    Button(action: {
                                        viewModel.showRefillSheet = true
                                    }) {
                                        Text("Refill")
                                            .font(TypographyTokens.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, SpacingTokens.md)
                                            .padding(.vertical, 8)
                                            .background(ColorTokens.primaryTeal)
                                            .clipShape(Capsule())
                                    }
                                    
                                    Button(action: {
                                        viewModel.showCorrectionSheet = true
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(ColorTokens.textSecondary)
                                            .padding(8)
                                            .background(ColorTokens.cardBorder.opacity(0.4))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                        .cardStyle(padding: SpacingTokens.md)
                    }
                    
                    // Control Actions (Pause/Resume & Delete)
                    VStack(spacing: SpacingTokens.md) {
                        SecondaryButton(
                            title: medicine.status == .active ? "Pause Medication" : "Resume Medication",
                            icon: medicine.status == .active ? "pause.fill" : "play.fill"
                        ) {
                            Task {
                                await viewModel.togglePauseResume()
                            }
                        }
                        
                        SecondaryButton(
                            title: "Delete Medication",
                            icon: "trash.fill",
                            isDestructive: true
                        ) {
                            viewModel.showDeleteConfirmation = true
                        }
                    }
                    .padding(.top, SpacingTokens.sm)
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xxl)
            } else if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 100)
            }
        }
        .background(ColorTokens.background.ignoresSafeArea())
        .navigationTitle(viewModel.medicine?.name ?? "Medicine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditModal = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditModal) {
            if let medicine = viewModel.medicine {
                EditMedicineView(medicine: medicine) {
                    Task {
                        await viewModel.loadDetails()
                    }
                }
            }
        }
        .alert("Delete Medication?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    let success = await viewModel.deleteMedicine()
                    if success {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this medicine? Future scheduled doses will be cleared, while your historical dose records will be preserved.")
        }
        .alert("Refill Inventory", isPresented: $viewModel.showRefillSheet) {
            TextField("Amount to add", text: $viewModel.refillAmountText)
                .keyboardType(.numberPad)
            Button("Add Refill") {
                Task {
                    await viewModel.refillInventory()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the number of units you purchased or received to add to the current inventory.")
        }
        .alert("Manual Inventory Count", isPresented: $viewModel.showCorrectionSheet) {
            TextField("Actual Count", text: $viewModel.correctedQuantityText)
                .keyboardType(.numberPad)
            Button("Save Count") {
                Task {
                    await viewModel.correctInventory()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter the exact remaining inventory count currently in your cabinet.")
        }
        .task {
            await viewModel.loadDetails()
        }
    }
}
