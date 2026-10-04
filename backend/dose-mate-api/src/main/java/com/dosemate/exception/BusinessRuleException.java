package com.dosemate.exception;

public class BusinessRuleException extends ApiException {

    public BusinessRuleException(ErrorCode errorCode) {
        super(errorCode);
    }

    public BusinessRuleException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }

    public BusinessRuleException(ErrorCode errorCode, String message, Object details) {
        super(errorCode, message, details);
    }
}
