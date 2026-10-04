import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingCountryPicker: Bool = false
    let onSaved: () -> Void
    
    init(user: UserDTO?, onSaved: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
        self.onSaved = onSaved
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: SpacingTokens.lg) {
                VStack(spacing: SpacingTokens.md) {
                    CustomTextField(
                        title: "Full Name",
                        placeholder: "Jane Doe",
                        text: $viewModel.fullName,
                        icon: "person.fill",
                        autocapitalization: .words
                    )
                    
                    // Date of Birth
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
                    
                    // Gender
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
                    
                    // Country
                    VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                        Text("Country")
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
                    .background(ColorTokens.statusMissedSubtle)
                    .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusSm))
                }
                
                PrimaryButton(title: "Save Profile", icon: "checkmark", isLoading: viewModel.isLoading) {
                    Task {
                        let success = await viewModel.saveProfile()
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
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingCountryPicker) {
            CountryPickerModal(selectedCountry: $viewModel.selectedCountry)
        }
    }
}
