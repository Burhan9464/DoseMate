package com.dosemate.dto.medicine;

import com.dosemate.entity.FrequencyMode;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.Set;

public class ScheduleDto {

    @NotNull(message = "Frequency mode is required")
    private FrequencyMode frequencyMode;

    @NotEmpty(message = "At least one day must be selected")
    private Set<DayOfWeek> days;

    @NotEmpty(message = "At least one medication time is required")
    private Set<LocalTime> times;

    public ScheduleDto() {
    }

    public ScheduleDto(FrequencyMode frequencyMode, Set<DayOfWeek> days, Set<LocalTime> times) {
        this.frequencyMode = frequencyMode;
        this.days = days;
        this.times = times;
    }

    public FrequencyMode getFrequencyMode() {
        return frequencyMode;
    }

    public void setFrequencyMode(FrequencyMode frequencyMode) {
        this.frequencyMode = frequencyMode;
    }

    public Set<DayOfWeek> getDays() {
        return days;
    }

    public void setDays(Set<DayOfWeek> days) {
        this.days = days;
    }

    public Set<LocalTime> getTimes() {
        return times;
    }

    public void setTimes(Set<LocalTime> times) {
        this.times = times;
    }
}
