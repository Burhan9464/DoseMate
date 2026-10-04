import SwiftUI

struct EditMedicineView: View {
    @StateObject private var viewModel: EditMedicineViewModel
    @Environment(\.dismiss) private var dismiss
    let onSaved: () -> Void
    
    init(medicine: MedicineDetailDTO, onSaved: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditMedicineViewModel(medicine: medicine))
        self.onSaved = onSaved
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpacingTokens.lg) {
                    // Medicine Basic Details
                    VStack(spacing: SpacingTokens.md) {
                        CustomTextField(
                            title: "Medicine Name",
                            placeholder: "Medicine Name",
                            text: $viewModel.name,
                            icon: "pills.fill",
                            autocapitalization: .words
                        )
                        
                        HStack(spacing: SpacingTokens.md) {
                            CustomTextField(
                                title: "Dosage Amount",
                                placeholder: "e.g., 500",
                                text: $viewModel.dosageValueText,
                                icon: "scalemass.fill",
                                keyboardType: .decimalPad
                            )
                            CustomTextField(
                                title: "Unit",
                                placeholder: "mg, ml",
                                text: $viewModel.dosageUnit,
                                icon: "tag.fill",
                                autocapitalization: .never
                            )
                        }
                        
                        Toggle("Ongoing Treatment", isOn: $viewModel.isOngoing)
                            .font(TypographyTokens.body)
                            .tint(ColorTokens.primaryTeal)
                        
                        DatePicker(
                            "Start Date",
                            selection: $viewModel.startDate,
                            displayedComponents: .date
                        )
                        
                        if !viewModel.isOngoing {
                            DatePicker(
                                "End Date",
                                selection: $viewModel.endDate,
                                in: viewModel.startDate...,
                                displayedComponents: .date
                            )
                        }
                        
                        CustomTextField(
                            title: "Instructions (Optional)",
                            placeholder: "Instructions",
                            text: $viewModel.instructions,
                            icon: "text.bubble.fill",
                            autocapitalization: .sentences
                        )
                    }
                    .cardStyle(padding: SpacingTokens.lg)
                    
                    // Schedule Card
                    VStack(alignment: .leading, spacing: SpacingTokens.md) {
                        Text("Medication Schedule")
                            .font(TypographyTokens.headline)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        Picker("Frequency", selection: $viewModel.frequencyMode) {
                            ForEach(FrequencyMode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.frequencyMode) { mode in
                            if mode == .multipleDaily && viewModel.scheduledTimes.count < 2 {
                                viewModel.addScheduledTime()
                            }
                        }
                        
                        // Days of week
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
                        
                        // Times
                        ForEach(0..<viewModel.scheduledTimes.count, id: \.self) { idx in
                            HStack {
                                DatePicker(
                                    "Time \(idx + 1)",
                                    selection: $viewModel.scheduledTimes[idx],
                                    displayedComponents: .hourAndMinute
                                )
                                .datePickerStyle(.compact)
                                
                                if viewModel.frequencyMode == .multipleDaily && viewModel.scheduledTimes.count > 1 {
                                    Button(action: {
                                        viewModel.removeScheduledTime(at: idx)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(ColorTokens.statusMissed)
                                    }
                                }
                            }
                        }
                        
                        if viewModel.frequencyMode == .multipleDaily {
                            Button(action: {
                                viewModel.addScheduledTime()
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
                    .cardStyle(padding: SpacingTokens.lg)
                    
                    // Inventory Card
                    VStack(alignment: .leading, spacing: SpacingTokens.md) {
                        Text("Inventory & Threshold")
                            .font(TypographyTokens.headline)
                            .foregroundColor(ColorTokens.textPrimary)
                        
                        CustomTextField(
                            title: "Low Stock Alert Threshold",
                            placeholder: "5",
                            text: $viewModel.lowStockThresholdText,
                            icon: "exclamationmark.triangle.fill",
                            keyboardType: .numberPad
                        )
                    }
                    .cardStyle(padding: SpacingTokens.lg)
                    
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
                    
                    PrimaryButton(title: "Save Changes", icon: "checkmark", isLoading: viewModel.isLoading) {
                        Task {
                            let success = await viewModel.updateMedicine()
                            if success {
                                onSaved()
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xxl)
            }
            .background(ColorTokens.background.ignoresSafeArea())
            .navigationTitle("Edit Medication")
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
}
