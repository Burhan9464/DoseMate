import SwiftUI

struct RegistrationSuccessView: View {
    let authData: AuthResponseData
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            ColorTokens.background
                .ignoresSafeArea()
            
            VStack(spacing: SpacingTokens.xl) {
                Spacer()
                
                // Success Badge
                ZStack {
                    Circle()
                        .fill(ColorTokens.statusTakenSubtle)
                        .frame(width: 110, height: 110)
                        .shadow(color: ColorTokens.statusTaken.opacity(0.2), radius: 14, x: 0, y: 6)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(ColorTokens.statusTaken)
                }
                
                VStack(spacing: SpacingTokens.sm) {
                    Text("Account Created!")
                        .font(TypographyTokens.title1)
                        .foregroundColor(ColorTokens.textPrimary)
                    
                    Text("Welcome to DoseMate, \(authData.user.fullName). Let's take a quick 1-minute tour to help you get the most out of your medication sanctuary.")
                        .font(TypographyTokens.body)
                        .foregroundColor(ColorTokens.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SpacingTokens.xl)
                        .lineSpacing(3)
                }
                
                Spacer()
                
                PrimaryButton(title: "Take Quick Tour", icon: "sparkles") {
                    HapticService.shared.success()
                    appState.setAuthenticated(token: authData.token, user: authData.user, isNewRegistration: true)
                }
                .padding(.horizontal, SpacingTokens.lg)
                .padding(.bottom, SpacingTokens.xl)
            }
        }
    }
}
