package com.dosemate.dto.user;

import com.dosemate.entity.Gender;
import com.dosemate.entity.User;

import java.time.LocalDate;

public class UserProfileResponse {

    private Long id;
    private String fullName;
    private String email;
    private LocalDate dateOfBirth;
    private Gender gender;
    private String country;
    private String timezone;
    private boolean onboardingCompleted;
    private boolean guideCompleted;

    public UserProfileResponse() {
    }

    public static UserProfileResponse fromEntity(User user) {
        UserProfileResponse response = new UserProfileResponse();
        response.setId(user.getId());
        response.setFullName(user.getFullName());
        response.setEmail(user.getEmail());
        response.setDateOfBirth(user.getDateOfBirth());
        response.setGender(user.getGender());
        response.setCountry(user.getCountry());
        response.setTimezone(user.getTimezone());
        response.setOnboardingCompleted(user.isOnboardingCompleted());
        response.setGuideCompleted(user.isGuideCompleted());
        return response;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public Gender getGender() {
        return gender;
    }

    public void setGender(Gender gender) {
        this.gender = gender;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getTimezone() {
        return timezone;
    }

    public void setTimezone(String timezone) {
        this.timezone = timezone;
    }

    public boolean isOnboardingCompleted() {
        return onboardingCompleted;
    }

    public void setOnboardingCompleted(boolean onboardingCompleted) {
        this.onboardingCompleted = onboardingCompleted;
    }

    public boolean isGuideCompleted() {
        return guideCompleted;
    }

    public void setGuideCompleted(boolean guideCompleted) {
        this.guideCompleted = guideCompleted;
    }
}
