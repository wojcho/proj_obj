package io.justedlev.msrv.kloudy.common;

import lombok.NonNull;
import org.springframework.data.domain.AuditorAware;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.JwtClaimAccessor;

import java.util.Optional;
import java.util.function.Predicate;

public class JwtSubjectAuditorAware implements AuditorAware<String> {

    @NonNull
    @Override
    public Optional<String> getCurrentAuditor() {
        return Optional.of(SecurityContextHolder.getContext())
                .map(SecurityContext::getAuthentication)
                .filter(Authentication::isAuthenticated)
                .filter(Predicate.not(AnonymousAuthenticationToken.class::isInstance))
                .map(Authentication::getPrincipal)
                .filter(JwtClaimAccessor.class::isInstance)
                .map(JwtClaimAccessor.class::cast)
                .map(JwtClaimAccessor::getSubject);
    }

}
