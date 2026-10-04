import SwiftUI

struct AddMedicineView: View {
    @StateObject private var viewModel = AddMedicineViewModel()
    @Environment(\.dismiss) private var dismiss
    let onSaved: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpacingTokens.lg) {
                    // Step Progress Indicator
                    HStack(spacing: SpacingTokens.sm) {
                        stepIndicator(number: 1, title: "Info", step: .information)
                        lineDivider(active: viewModel.currentStep.rawValue >= 2)
                        stepIndicator(number: 2, title: "Schedule", step: .schedule)
                        lineDivider(active: viewModel.currentStep.rawValue >= 3)
                        stepIndicator(number: 3, title: "Inventory", step: .inventory)
                    }
                    .padding(.top, SpacingTokens.sm)
                    
                    // Card Content Based on Current Step
                    switch viewModel.currentStep {
                    case .information:
                        step1InformationView
                    case .schedule:
                        step2ScheduleView
                    case .inventory:
                        step3InventoryView
                    }
                    
                    // Error Notice if Any
                    if let error = viewModel.errorMessage {
                        HStack(spacing: SpacingTokens.xs) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(ColorTokens.statusMissed)
                            Text(error)
                                .font(TypographyTokens.footnote)
                                .foregroundColor(ColorTokens.statusMissed)
                        }
                        .padding(SpacingTokens.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(ColorTokens.statusMissedSubtle)
                        .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusSm))
                    }
                    
                    // Navigation Buttons
                    HStack(spacing: SpacingTokens.md) {
                        if viewModel.currentStep != .information {
                            SecondaryButton(title: "Back", icon: "chevron.left") {
                                withAnimation {
                                    if viewModel.currentStep == .inventory {
                                        viewModel.currentStep = .schedule
                                    } else if viewModel.currentStep == .schedule {
                                        viewModel.currentStep = .information
                                    }
                                }
                            }
                        }
                        
                        if viewModel.currentStep != .inventory {
                            PrimaryButton(title: "Next", icon: "chevron.right") {
                                withAnimation {
                                    if viewModel.currentStep == .information && viewModel.validateStep1() {
                                        viewModel.currentStep = .schedule
                                    } else if viewModel.currentStep == .schedule && viewModel.validateStep2() {
                                        viewModel.currentStep = .inventory
                                    }
                                }
                            }
                        } else {
                            PrimaryButton(title: "Save Medication", icon: "checkmark", isLoading: viewModel.isLoading) {
                                Task {
                                    let success = await viewModel.saveMedicine()
                                    if success {
                                        onSaved()
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xxl)
            }
            .background(ColorTokens.background.ignoresSafeArea())
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Step 1: Information
    private var step1InformationView: some View {
        VStack(spacing: SpacingTokens.md) {
            CustomTextField(
                title: "Medicine Name",
                placeholder: "e.g., Amoxicillin, Lisinopril",
                text: $viewModel.name,
                icon: "pills.fill",
                autocapitalization: .words,
                errorMessage: viewModel.nameError
            )
            
            HStack(spacing: SpacingTokens.md) {
                CustomTextField(
                    title: "Dosage Amount",
                    placeholder: "e.g., 500",
                    text: $viewModel.dosageValueText,
                    icon: "scalemass.fill",
                    keyboardType: .decimalPad,
                    errorMessage: viewModel.dosageError
                )
                
                CustomTextField(
                    title: "Unit",
                    placeholder: "mg, ml, drops",
                    text: $viewModel.dosageUnit,
                    icon: "tag.fill",
                    autocapitalization: .never
                )
            }
            
            // Medicine Type Picker
            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                Text("Medicine Type")
                    .font(TypographyTokens.subheadline)
                    .foregroundColor(ColorTokens.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpacingTokens.xs) {
                        ForEach(MedicineType.allCases) { type in
                            Button(action: {
                                viewModel.selectedType = type
                                HapticService.shared.selection()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: type.iconName)
                                    Text(type.displayName)
                                }
                                .font(TypographyTokens.caption)
                                .fontWeight(viewModel.selectedType == type ? .bold : .regular)
                                .padding(.horizontal, SpacingTokens.md)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedType == type ? ColorTokens.primaryTeal : ColorTokens.cardBorder.opacity(0.3))
                                .foregroundColor(viewModel.selectedType == type ? .white : ColorTokens.textPrimary)
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            
            // Ongoing Treatment Toggle
            Toggle("Ongoing Medication", isOn: $viewModel.isOngoing)
                .font(TypographyTokens.body)
                .tint(ColorTokens.primaryTeal)
                .padding(.top, SpacingTokens.xs)
            
            // Start Date
            DatePicker(
                "Start Date",
                selection: $viewModel.startDate,
                displayedComponents: .date
            )
            .font(TypographyTokens.body)
            
            // End Date (if not ongoing)
            if !viewModel.isOngoing {
                DatePicker(
                    "End Date",
                    selection: $viewModel.endDate,
                    in: viewModel.startDate...,
                    displayedComponents: .date
                )
                .font(TypographyTokens.body)
            }
            
            // Optional Instructions
            CustomTextField(
                title: "Instructions (Optional)",
                placeholder: "e.g., Take with a full glass of water after food",
                text: $viewModel.instructions,
                icon: "text.bubble.fill",
                autocapitalization: .sentences
            )
        }
        .cardStyle(padding: SpacingTokens.lg)
    }
    
    // MARK: - Step 2: Schedule
    private var step2ScheduleView: some View {
        VStack(spacing: SpacingTokens.md) {
            // Frequency Mode Segmented Picker
            Picker("Frequency", selection: $viewModel.frequencyMode) {
                ForEach(FrequencyMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.frequencyMode) { mode in
                if mode == .multipleDaily && viewModel.scheduledTimes.count < 2 {
                    viewModel.addScheduledTime()
                } else if mode == .onceDaily && viewModel.scheduledTimes.count > 1 {
                    viewModel.scheduledTimes = [viewModel.scheduledTimes[0]]
                }
            }
            
            // Day Selection Pills
            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                Text("Days of the Week")
                    .font(TypographyTokens.subheadline)
                    .foregroundColor(ColorTokens.textSecondary)
                
                HStack(spacing: 6) {
                    ForEach(DayOfWeek.allCases) { day in
                        let isSelected = viewModel.selectedDays.contains(day)
                        Button(action: {
                            if isSelected {
                                if viewModel.selectedDays.count > 1 {
                                    viewModel.selectedDays.remove(day)
                                }
                            } else {
                                viewModel.selectedDays.insert(day)
                            }
                            HapticService.shared.selection()
                        }) {
                            Text(day.singleLetter)
                                .font(TypographyTokens.footnote)
                                .fontWeight(.bold)
                                .frame(width: 38, height: 38)
                                .background(isSelected ? ColorTokens.primaryTeal : ColorTokens.cardBorder.opacity(0.3))
                                .foregroundColor(isSelected ? .white : ColorTokens.textPrimary)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            // Scheduled Times List
            VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                HStack {
                    Text("Daily Medication Times")
                        .font(TypographyTokens.subheadline)
                        .foregroundColor(ColorTokens.textSecondary)
                    Spacer()
                    if viewModel.frequencyMode == .multipleDaily {
                        Button(action: {
                            viewModel.addScheduledTime()
                            HapticService.shared.selection()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Time")
                            }
                            .font(TypographyTokens.caption)
                            .foregroundColor(ColorTokens.primaryTeal)
                        }
                    }
                }
                
                ForEach(0..<viewModel.scheduledTimes.count, id: \.self) { idx in
                    HStack {
                        DatePicker(
                            "Time \(idx + 1)",
                            selection: $viewModel.scheduledTimes[idx],
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.compact)
                        
                        if viewModel.frequencyMode == .multipleDaily && viewModel.scheduledTimes.count > 2 {
                            Button(action: {
                                viewModel.removeScheduledTime(at: idx)
                                HapticService.shared.selection()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(ColorTokens.statusMissed)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            if let error = viewModel.scheduleError {
                Text(error)
                    .font(TypographyTokens.caption)
                    .foregroundColor(ColorTokens.statusMissed)
            }
        }
        .cardStyle(padding: SpacingTokens.lg)
    }
    
    // MARK: - Step 3: Inventory
    private var step3InventoryView: some View {
        VStack(spacing: SpacingTokens.md) {
            CustomTextField(
                title: "Starting Stock Quantity",
                placeholder: "30",
                text: $viewModel.inventoryQuantityText,
                icon: "shippingbox.fill",
                keyboardType: .numberPad,
                errorMessage: viewModel.inventoryError
            )
            
            CustomTextField(
                title: "Inventory Unit",
                placeholder: "e.g., tablets, capsules, ml",
                text: $viewModel.inventoryUnit,
                icon: "tag.fill",
                autocapitalization: .never
            )
            
            CustomTextField(
                title: "Low Stock Alert Threshold",
                placeholder: "e.g., 5",
                text: $viewModel.lowStockThresholdText,
                icon: "exclamationmark.triangle.fill",
                keyboardType: .numberPad
            )
            
            Text("When remaining inventory falls below or equal to this number, DoseMate will flag an alert on your dashboard so you have time to refill.")
                .font(TypographyTokens.caption)
                .foregroundColor(ColorTokens.textSecondary)
                .padding(.horizontal, SpacingTokens.xs)
        }
        .cardStyle(padding: SpacingTokens.lg)
    }
    
    // MARK: - Helper UI Builders
    private func stepIndicator(number: Int, title: String, step: AddMedicineStep) -> some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(viewModel.currentStep == step ? ColorTokens.primaryTeal : (viewModel.currentStep.rawValue > step.rawValue ? ColorTokens.statusTaken : ColorTokens.cardBorder))
                    .frame(width: 24, height: 24)
                if viewModel.currentStep.rawValue > step.rawValue {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(TypographyTokens.micro)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.currentStep == step ? .white : ColorTokens.textSecondary)
                }
            }
            Text(title)
                .font(TypographyTokens.caption)
                .fontWeight(viewModel.currentStep == step ? .bold : .medium)
                .foregroundColor(viewModel.currentStep == step ? ColorTokens.primaryTeal : ColorTokens.textSecondary)
        }
    }
    
    private func lineDivider(active: Bool) -> some View {
        Rectangle()
            .fill(active ? ColorTokens.primaryTeal : ColorTokens.cardBorder)
            .frame(height: 2)
    }
}
