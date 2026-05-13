package io.justedlev.msrv.kloudy.configuration.properties;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.nio.file.Path;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "kloudy")
public class KloudyProperties {
    private Path root = Path.of("./.tmp");
}
