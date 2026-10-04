import SwiftUI

struct CountryPickerModal: View {
    @Binding var selectedCountry: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    var filteredCountries: [CountryItem] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return CountryHelper.allCountries
        }
        return CountryHelper.allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.code.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: SpacingTokens.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ColorTokens.textMuted)
                    TextField("Search countries...", text: $searchText)
                        .font(TypographyTokens.body)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(ColorTokens.textMuted)
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.md)
                .frame(height: 44)
                .background(ColorTokens.cardBorder.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusSm, style: .continuous))
                .padding(.horizontal, SpacingTokens.md)
                .padding(.vertical, SpacingTokens.sm)
                
                List {
                    ForEach(filteredCountries) { country in
                        Button(action: {
                            selectedCountry = country.name
                            HapticService.shared.selection()
                            dismiss()
                        }) {
                            HStack(spacing: SpacingTokens.md) {
                                Text(country.flag)
                                    .font(.system(size: 24))
                                Text(country.name)
                                    .font(TypographyTokens.body)
                                    .foregroundColor(ColorTokens.textPrimary)
                                Spacer()
                                if selectedCountry == country.name {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(ColorTokens.primaryTeal)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
