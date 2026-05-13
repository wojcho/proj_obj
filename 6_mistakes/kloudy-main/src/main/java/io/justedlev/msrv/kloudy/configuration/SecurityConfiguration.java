package io.justedlev.msrv.kloudy.configuration;

import io.justedlev.msrv.kloudy.configuration.properties.SecurityProperties;
import io.justedlev.msrv.kloudy.controller.FilesController;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.security.oauth2.resource.OAuth2ResourceServerProperties;
import org.springframework.boot.context.properties.PropertyMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.session.SessionRegistryImpl;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.DelegatingJwtGrantedAuthoritiesConverter;
import org.springframework.security.oauth2.server.resource.authentication.ExpressionJwtGrantedAuthoritiesConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.session.RegisterSessionAuthenticationStrategy;
import org.springframework.security.web.authentication.session.SessionAuthenticationStrategy;

import java.util.Collection;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(jsr250Enabled = true, securedEnabled = true)
@RequiredArgsConstructor
public class SecurityConfiguration {
    private static final ExpressionParser PARSER = new SpelExpressionParser();
    private static final PropertyMapper PROPERTY_MAPPER = PropertyMapper.get().alwaysApplyingWhenNonNull();
    private static final String ROLE_PREFIX = "ROLE_";

    private final SecurityProperties properties;

    @Bean
    public SecurityFilterChain securityFilterChain(@NonNull HttpSecurity httpSecurity) throws Exception {
        return httpSecurity
                .csrf(AbstractHttpConfigurer::disable)
                .formLogin(AbstractHttpConfigurer::disable)
                .oauth2ResourceServer(configurer -> configurer.jwt(Customizer.withDefaults()))
                .sessionManagement(configurer -> configurer.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(registry -> {
                    properties.getWhitelist().forEach((k, v) -> registry.requestMatchers(k, v).permitAll());
                    var filesPath = FilesController.CONTEXT_PATH + "/**";
                    registry.requestMatchers(HttpMethod.GET, filesPath)
                            .hasAnyAuthority(
                                    "SCOPE_kloudy.files:read",
                                    "ROLE_user"
                            );
                    registry.requestMatchers(HttpMethod.POST, filesPath)
                            .hasAnyAuthority(
                                    "SCOPE_kloudy.files:write",
                                    "ROLE_user"
                            );
                    registry.requestMatchers(HttpMethod.DELETE, filesPath)
                            .hasAnyAuthority(
                                    "ROLE_admin"
                            );
                    registry.anyRequest().authenticated();
                })
                .build();
    }

    @Bean
    SessionAuthenticationStrategy sessionAuthenticationStrategy() {
        return new RegisterSessionAuthenticationStrategy(new SessionRegistryImpl());
    }

    @Bean
    JwtAuthenticationConverter jwtAuthenticationConverter(
            OAuth2ResourceServerProperties properties,
            Collection<Converter<Jwt, Collection<GrantedAuthority>>> converters
    ) {
        var jwtAuthenticationConverter = new JwtAuthenticationConverter();
        PROPERTY_MAPPER.from(properties.getJwt()::getPrincipalClaimName).to(jwtAuthenticationConverter::setPrincipalClaimName);
        jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter(new DelegatingJwtGrantedAuthoritiesConverter(converters));

        return jwtAuthenticationConverter;
    }

    @Bean
    ExpressionJwtGrantedAuthoritiesConverter resourceAccessRolesJwtGrantedAuthoritiesConverter() {
        var exp = PARSER.parseExpression("[resource_access][[azp][0]][roles]");
        var converter = new ExpressionJwtGrantedAuthoritiesConverter(exp);
        converter.setAuthorityPrefix(ROLE_PREFIX);

        return converter;
    }

    @Bean
    ExpressionJwtGrantedAuthoritiesConverter realmAccessRolesJwtGrantedAuthoritiesConverter() {
        var exp = PARSER.parseExpression("[realm_access][roles]");
        var converter = new ExpressionJwtGrantedAuthoritiesConverter(exp);
        converter.setAuthorityPrefix(ROLE_PREFIX);

        return converter;
    }

    @Bean
    JwtGrantedAuthoritiesConverter jwtGrantedAuthoritiesConverter(OAuth2ResourceServerProperties properties) {
        var converter = new JwtGrantedAuthoritiesConverter();
        PROPERTY_MAPPER.from(properties.getJwt()::getAuthorityPrefix).to(converter::setAuthorityPrefix);
        PROPERTY_MAPPER.from(properties.getJwt()::getAuthoritiesClaimDelimiter).to(converter::setAuthoritiesClaimDelimiter);
        PROPERTY_MAPPER.from(properties.getJwt()::getAuthoritiesClaimName).to(converter::setAuthoritiesClaimName);

        return converter;
    }

}
