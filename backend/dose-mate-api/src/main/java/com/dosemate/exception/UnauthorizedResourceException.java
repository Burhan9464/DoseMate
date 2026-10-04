package com.dosemate.exception;

public class UnauthorizedResourceException extends ApiException {

    public UnauthorizedResourceException() {
        super(ErrorCode.FORBIDDEN, "You do not have permission to access or modify this resource.");
    }

    public UnauthorizedResourceException(String message) {
        super(ErrorCode.FORBIDDEN, message);
    }
}
