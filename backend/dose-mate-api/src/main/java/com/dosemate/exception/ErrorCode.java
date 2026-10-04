package com.dosemate.exception;

import org.springframework.http.HttpStatus;

public enum ErrorCode {
    VALIDATION_FAILED(HttpStatus.BAD_REQUEST, "Validation failed for one or more fields."),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "Invalid email or password."),
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "Authentication required or token expired."),
    FORBIDDEN(HttpStatus.FORBIDDEN, "Access to this resource is forbidden."),
    RESOURCE_NOT_FOUND(HttpStatus.NOT_FOUND, "The requested resource was not found."),
    DUPLICATE_EMAIL(HttpStatus.CONFLICT, "An account with this email address already exists."),
    DOSE_ALREADY_COMPLETED(HttpStatus.CONFLICT, "This dose has already been taken."),
    DOSE_NOT_PENDING(HttpStatus.CONFLICT, "Dose is not in a pending state."),
    UNDO_WINDOW_EXPIRED(HttpStatus.BAD_REQUEST, "The allowed window to undo this action has expired."),
    INSUFFICIENT_INVENTORY(HttpStatus.BAD_REQUEST, "Insufficient medication inventory for this dose."),
    MEDICINE_ALREADY_PAUSED(HttpStatus.CONFLICT, "Medicine is already paused."),
    MEDICINE_ALREADY_ACTIVE(HttpStatus.CONFLICT, "Medicine is already active."),
    INVALID_SCHEDULE(HttpStatus.BAD_REQUEST, "The provided medication schedule is invalid."),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "An internal server error occurred.");

    private final HttpStatus httpStatus;
    private final String defaultMessage;

    ErrorCode(HttpStatus httpStatus, String defaultMessage) {
        this.httpStatus = httpStatus;
        this.defaultMessage = defaultMessage;
    }

    public HttpStatus getHttpStatus() {
        return httpStatus;
    }

    public String getDefaultMessage() {
        return defaultMessage;
    }
}
