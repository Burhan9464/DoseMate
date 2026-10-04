import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpacingTokens.md) {
                // Search Field
                HStack(spacing: SpacingTokens.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ColorTokens.textMuted)
                    TextField("Search history by medicine...", text: $viewModel.searchText)
                        .font(TypographyTokens.body)
                        .onSubmit {
                            Task { await viewModel.loadHistory() }
                        }
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                            Task { await viewModel.loadHistory() }
                        }) {
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
                
                // Status Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpacingTokens.xs) {
                        ForEach(viewModel.filterOptions, id: \.self) { filter in
                            let isSelected = viewModel.selectedFilter == filter
                            Button(action: {
                                viewModel.selectedFilter = filter
                                HapticService.shared.selection()
                                Task { await viewModel.loadHistory() }
                            }) {
                                Text(filter.capitalized)
                                    .font(TypographyTokens.footnote)
                                    .fontWeight(isSelected ? .bold : .medium)
                                    .padding(.horizontal, SpacingTokens.md)
                                    .padding(.vertical, 7)
                                    .background(isSelected ? ColorTokens.primaryTeal : ColorTokens.cardBackground)
                                    .foregroundColor(isSelected ? .white : ColorTokens.textPrimary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? Color.clear : ColorTokens.cardBorder, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(.vertical, SpacingTokens.xs)
                
                // Grouped Records List
                if !viewModel.groupedHistory.isEmpty {
                    ForEach(viewModel.groupedHistory) { group in
                        VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                            Text(group.dateHeader)
                                .font(TypographyTokens.headline)
                                .foregroundColor(ColorTokens.textSecondary)
                                .padding(.top, SpacingTokens.xs)
                            
                            ForEach(group.doses) { dose in
                                DoseCard(dose: dose)
                            }
                        }
                    }
                } else if !viewModel.isLoading {
                    // Empty or No Results State
                    if !viewModel.searchText.isEmpty || viewModel.selectedFilter != "ALL" {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No Matching Doses",
                            message: "We couldn't find any medication records matching '\(viewModel.searchText.isEmpty ? viewModel.selectedFilter : viewModel.searchText)'.",
                            buttonTitle: "Clear Filters"
                        ) {
                            viewModel.searchText = ""
                            viewModel.selectedFilter = "ALL"
                            Task { await viewModel.loadHistory() }
                        }
                    } else {
                        EmptyStateView(
                            icon: "clock.arrow.circlepath",
                            title: "No History Yet",
                            message: "Your medication history will record here automatically as doses are taken or skipped."
                        )
                    }
                }
            }
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.bottom, SpacingTokens.xxl)
        }
        .background(ColorTokens.background.ignoresSafeArea())
        .navigationTitle("History")
        .refreshable {
            await viewModel.loadHistory()
        }
        .task {
            await viewModel.loadHistory()
        }
    }
}
