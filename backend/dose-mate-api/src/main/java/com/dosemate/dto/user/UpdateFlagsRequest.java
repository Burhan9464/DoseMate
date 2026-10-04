package com.dosemate.dto.user;

public class UpdateFlagsRequest {

    private Boolean onboardingCompleted;
    private Boolean guideCompleted;

    public UpdateFlagsRequest() {
    }

    public Boolean getOnboardingCompleted() {
        return onboardingCompleted;
    }

    public void setOnboardingCompleted(Boolean onboardingCompleted) {
        this.onboardingCompleted = onboardingCompleted;
    }

    public Boolean getGuideCompleted() {
        return guideCompleted;
    }

    public void setGuideCompleted(Boolean guideCompleted) {
        this.guideCompleted = guideCompleted;
    }
}
