import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject private var appState: AppState
    let onNavigateToMedicines: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: SpacingTokens.lg) {
                        // Header Greeting & User Badge
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                                Text(viewModel.dashboardData?.greeting ?? "Hello, \(appState.currentUser?.fullName.components(separatedBy: " ").first ?? "there")")
                                    .font(TypographyTokens.title1)
                                    .foregroundColor(ColorTokens.textPrimary)
                                
                                Text(Date().toMediumDateString)
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Status / Profile Initials
                            ZStack {
                                Circle()
                                    .fill(ColorTokens.primaryTealSubtle)
                                    .frame(width: 44, height: 44)
                                Text(appState.currentUser?.fullName.prefix(1).uppercased() ?? "D")
                                    .font(TypographyTokens.headline)
                                    .foregroundColor(ColorTokens.primaryTealDark)
                            }
                        }
                        .padding(.top, SpacingTokens.sm)
                        
                        // Error Banner if present
                        if let error = viewModel.errorMessage {
                            HStack(spacing: SpacingTokens.sm) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(ColorTokens.statusMissed)
                                Text(error)
                                    .font(TypographyTokens.footnote)
                                    .foregroundColor(ColorTokens.statusMissed)
                                Spacer()
                                Button("Dismiss") {
                                    viewModel.errorMessage = nil
                                }
                                .font(TypographyTokens.caption)
                                .foregroundColor(ColorTokens.statusMissed)
                            }
                            .padding(SpacingTokens.sm)
                            .background(ColorTokens.statusMissedSubtle)
                            .clipShape(RoundedRectangle(cornerRadius: SpacingTokens.radiusSm))
                        }
                        
                        // Daily Adherence Progress Card
                        if let progress = viewModel.dashboardData?.dailyProgress {
                            CircularProgressView(
                                progress: progress.progressFraction,
                                takenDoses: progress.takenDoses,
                                totalDoses: progress.totalScheduledDoses,
                                skippedDoses: progress.skippedDoses
                            )
                        }
                        
                        // Conditional Needs Attention Section
                        if let attentionList = viewModel.dashboardData?.needsAttention, !attentionList.isEmpty {
                            VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                                Text("Needs Attention")
                                    .font(TypographyTokens.headline)
                                    .foregroundColor(ColorTokens.textPrimary)
                                
                                ForEach(attentionList) { item in
                                    AttentionCard(item: item) {
                                        onNavigateToMedicines()
                                    }
                                }
                            }
                        }
                        
                        // Current / Due Dose Section
                        if let currentDose = viewModel.dashboardData?.currentDose {
                            VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                                HStack {
                                    Text("Due Now")
                                        .font(TypographyTokens.headline)
                                        .foregroundColor(ColorTokens.textPrimary)
                                    Spacer()
                                }
                                
                                DoseCard(
                                    dose: currentDose,
                                    isCurrentDue: true,
                                    onSkip: {
                                        Task {
                                            await viewModel.skipCurrentDose(doseId: currentDose.id)
                                        }
                                    }
                                )
                                
                                // Drag-to-Take Pill Interaction
                                if currentDose.status == .pending {
                                    DragToTakePillView(isSubmitting: viewModel.isTakingDose) {
                                        Task {
                                            await viewModel.takeCurrentDose(doseId: currentDose.id)
                                        }
                                    }
                                    .padding(.top, SpacingTokens.xs)
                                }
                            }
                        } else if let totalDoses = viewModel.dashboardData?.dailyProgress.totalScheduledDoses, totalDoses > 0 {
                            // All doses taken for today
                            VStack(spacing: SpacingTokens.sm) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32))
                                    .foregroundColor(ColorTokens.primaryTeal)
                                Text("All Done for Today!")
                                    .font(TypographyTokens.headline)
                                    .foregroundColor(ColorTokens.textPrimary)
                                Text("You have completed all scheduled medications.")
                                    .font(TypographyTokens.subheadline)
                                    .foregroundColor(ColorTokens.textSecondary)
                            }
                            .cardStyle()
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Next Up Section
                        if let nextUp = viewModel.dashboardData?.nextUp {
                            VStack(alignment: .leading, spacing: SpacingTokens.xs) {
                                Text("Next Up")
                                    .font(TypographyTokens.headline)
                                    .foregroundColor(ColorTokens.textPrimary)
                                
                                HStack(spacing: SpacingTokens.md) {
                                    ZStack {
                                        Circle()
                                            .fill(ColorTokens.secondarySkySubtle)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(ColorTokens.secondarySky)
                                            .font(.system(size: 18))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(nextUp.medicineName)
                                            .font(TypographyTokens.headline)
                                            .foregroundColor(ColorTokens.textPrimary)
                                        Text(nextUp.dosage)
                                            .font(TypographyTokens.subheadline)
                                            .foregroundColor(ColorTokens.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(nextUp.formattedTime)
                                        .font(TypographyTokens.footnote)
                                        .fontWeight(.medium)
                                        .foregroundColor(ColorTokens.secondarySky)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(ColorTokens.secondarySkySubtle)
                                        .clipShape(Capsule())
                                }
                                .cardStyle(padding: SpacingTokens.md)
                            }
                        }
                        
                        // Empty State if no medicines exist
                        if viewModel.dashboardData?.dailyProgress.totalScheduledDoses == 0 &&
                            viewModel.dashboardData?.currentDose == nil &&
                            viewModel.dashboardData?.nextUp == nil {
                            EmptyStateView(
                                icon: "pills.circle.fill",
                                title: "No Medicines Scheduled",
                                message: "Add your medications to receive reminders and track doses easily.",
                                buttonTitle: "Add Your First Medicine"
                            ) {
                                onNavigateToMedicines()
                            }
                        }
                    }
                    .padding(.horizontal, SpacingTokens.lg)
                    .padding(.bottom, 100) // Space for bottom tab bar and undo toast
                }
                .refreshable {
                    await viewModel.loadDashboard()
                }
                
                // Floating Undo Toast
                if viewModel.showUndoToast {
                    ToastBanner(
                        message: viewModel.undoToastMessage,
                        type: .undo {
                            Task {
                                await viewModel.undoLastSkip()
                            }
                        }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 16)
                }
            }
            .background(ColorTokens.background.ignoresSafeArea())
            .navigationTitle("DoseMate")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadDashboard()
            }
        }
    }
}
