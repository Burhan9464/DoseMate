package com.dosemate.util;

import com.dosemate.exception.ApiException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.security.CustomUserDetails;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static CustomUserDetails getCurrentUserDetails() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof CustomUserDetails userDetails) {
            return userDetails;
        }
        throw new ApiException(ErrorCode.UNAUTHORIZED, "User is not authenticated");
    }

    public static Long getCurrentUserId() {
        return getCurrentUserDetails().getId();
    }
}
