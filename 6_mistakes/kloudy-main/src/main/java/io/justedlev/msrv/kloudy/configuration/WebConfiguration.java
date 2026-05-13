package io.justedlev.msrv.kloudy.configuration;

import lombok.NonNull;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfiguration implements WebMvcConfigurer {
    private static final String ALL = "*";

    @Override
    public void addCorsMappings(@NonNull CorsRegistry registry) {
        registry
                .addMapping("/**")
                .allowedOriginPatterns(ALL)
                .allowCredentials(true)
                .allowedMethods(
                        HttpMethod.GET.name(),
                        HttpMethod.POST.name(),
                        HttpMethod.PUT.name(),
                        HttpMethod.PATCH.name(),
                        HttpMethod.DELETE.name(),
                        HttpMethod.OPTIONS.name()
                )
                .allowedHeaders(ALL);
    }
}
