package io.justedlev.msrv.kloudy.configuration;

import io.justedlev.msrv.kloudy.common.JwtSubjectAuditorAware;
import io.justedlev.msrv.kloudy.common.SaftyModelMapper;
import io.justedlev.msrv.kloudy.configuration.properties.KloudyProperties;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.nio.file.Files;

@Slf4j
@Configuration
@EnableJpaAuditing(auditorAwareRef = "auditorAware")
public class KloudyConfiguration {

    @Bean
    public ModelMapper modelMapper() {
        return new SaftyModelMapper();
    }

    @Bean
    public AuditorAware<String> auditorAware() {
        return new JwtSubjectAuditorAware();
    }

    @Bean
    public CommandLineRunner kloudyPreLoadCmd(KloudyProperties props) {
        return args -> {

            if (Files.exists(props.getRoot())) {
                log.info("Kloudy root directory found: {}", props.getRoot().toAbsolutePath());
                return;
            }

            Files.createDirectory(props.getRoot());
            log.debug("Created kloudy root directory: {}", props.getRoot().toAbsolutePath());

        };
    }

}
