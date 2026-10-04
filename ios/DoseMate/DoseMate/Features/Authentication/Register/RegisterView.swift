import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingCountryPicker: Bool = false
    
    var body: some View {
        Group {
            if viewModel.isRegistrationSuccessful, let authData = viewModel.registeredAuthData {
                RegistrationSuccessView(authData: authData)
            } else {
                ScrollView {
                    VStack(spacing: SpacingTokens.lg) {
                        // Step Indicator
                        HStack(spacing: SpacingTokens.sm) {
                            stepBadge(number: 1, title: "Account", active: viewModel.currentStep == .account)
                            Rectangle()
                                .fill(viewModel.currentStep == .personal ? ColorTokens.primaryTeal : ColorTokens.cardBorder)
                                .frame(height: 2)
                            stepBadge(number: 2, title: "Personal", active: viewModel.currentStep == .personal)
                        }
                        .padding(.top, SpacingTokens.sm)
                        
                        // Header
                        VStack(spacing: SpacingTokens.xs) {
                            Text(viewModel.currentStep == .account ? "Create Your Account" : "Personal Details")
                                .font(TypographyTokens.title1)
                                .foregroundColor(ColorTokens.textPrimary)
                            
                            Text(viewModel.currentStep == .account
                                 ? "Step 1 of 2: Set your login credentials"
                                 : "Step 2 of 2: Tell us a bit about you")
                                .font(TypographyTokens.subheadline)
                                .foregroundColor(ColorTokens.textSecondary)
                        }
                        
                        // Form Card
                        VStack(spacing: SpacingTokens.md) {
                            if viewModel.currentStep == .account {
                                CustomTextField(
                                    title: "Full Name",
                                    placeholder: "Jane Doe",
                                    text: $viewModel.fullName,
                                    icon: "person.fill",
                                    autocapitalization: .words,
                                    errorMessage: viewModel.fullNameError
                                )
                                
                                CustomTextField(
                                    title: "Email Address",
                                    placeholder: "jane@example.com",
                                    text: $viewModel.email,
                                    icon: "envelope.fill",
                                    keyboardType: .emailAddress,
                                    autocapitalization: .never,
                                    errorMessage: viewModel.emailError
                                )
                                
                                CustomTextField(
                                    title: "Password",
                                    placeholder: "Minimum 8 characters",
                                    text: $viewModel.password,
                                    icon: "lock.fill",
                                    isSecure: true,
                                    errorMessage: viewModel.passwordError
                                )
                                
                                CustomTextField(
                                    title: "Confirm Password",
                                    placeholder: "Re-enter password",
                                    text: $viewModel.confirmPassword,
                                    icon: "lock.shield.fill",
                                    isSecure: true,
                                    errorMessage: viewModel.confirmPasswordError
                                )
                            } else {
                                // Date of Birth Picker
                                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                                    Text("Date of Birth")
                                        .font(TypographyTokens.subheadline)
                                        .foregroundColor(ColorTokens.textSecondary)
                                    
                                    DatePicker(
                                        "Select Date of Birth",
                                        selection: $viewModel.dateOfBirth,
                                        in: ...Date(),
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                    .padding(.horizontal, SpacingTokens.md)
                                    .frame(height: SpacingTokens.inputHeight)
                                    .background(ColorTokens.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: SpacingTokens.radiusMd)
                                            .stroke(ColorTokens.cardBorder, lineWidth: 1)
                                    )
                                }
                                
                                // Gender Selector
                                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                                    Text("Gender")
                                        .font(TypographyTokens.subheadline)
                                        .foregroundColor(ColorTokens.textSecondary)
                                    
                                    Picker("Gender", selection: $viewModel.gender) {
                                        Text("Female").tag("FEMALE")
                                        Text("Male").tag("MALE")
                                        Text("Other").tag("OTHER")
                                        Text("Prefer not to say").tag("PREFER_NOT_TO_SAY")
                                    }
                                    .pickerStyle(.segmented)
                                }
                                
                                // Country Selector
                                VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                                    Text("Country of Residence")
                                        .font(TypographyTokens.subheadline)
                                        .foregroundColor(ColorTokens.textSecondary)
                                    
                                    Button(action: {
                                        isShowingCountryPicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "globe")
                                                .foregroundColor(ColorTokens.primaryTeal)
                                            Text(viewModel.selectedCountry)
                                                .font(TypographyTokens.body)
                                                .foregroundColor(ColorTokens.textPrimary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(ColorTokens.textMuted)
                                        }
                                        .padding(.horizontal, SpacingTokens.md)
                                        .frame(height: SpacingTokens.inputHeight)
                                        .background(ColorTokens.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusMd))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: SpacingTokens.radiusMd)
                                                .stroke(ColorTokens.cardBorder, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            
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
                        }
                        .cardStyle(padding: SpacingTokens.lg)
                        
                        // Action Buttons
                        VStack(spacing: SpacingTokens.md) {
                            if viewModel.currentStep == .account {
                                PrimaryButton(title: "Continue to Step 2", icon: "arrow.right") {
                                    viewModel.proceedToStep2()
                                }
                            } else {
                                PrimaryButton(
                                    title: "Create Account",
                                    icon: "checkmark",
                                    isLoading: viewModel.isLoading
                                ) {
                                    Task {
                                        _ = await viewModel.register()
                                    }
                                }
                                
                                SecondaryButton(title: "Back to Step 1", icon: "arrow.left") {
                                    viewModel.backToStep1()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, SpacingTokens.lg)
                    .padding(.bottom, SpacingTokens.xxl)
                }
                .background(ColorTokens.background.ignoresSafeArea())
                .sheet(isPresented: $isShowingCountryPicker) {
                    CountryPickerModal(selectedCountry: $viewModel.selectedCountry)
                }
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
    
    private func stepBadge(number: Int, title: String, active: Bool) -> some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(active ? ColorTokens.primaryTeal : ColorTokens.cardBorder)
                    .frame(width: 24, height: 24)
                Text("\(number)")
                    .font(TypographyTokens.micro)
                    .fontWeight(.bold)
                    .foregroundColor(active ? .white : ColorTokens.textSecondary)
            }
            Text(title)
                .font(TypographyTokens.caption)
                .fontWeight(active ? .bold : .medium)
                .foregroundColor(active ? ColorTokens.primaryTeal : ColorTokens.textSecondary)
        }
    }
}
