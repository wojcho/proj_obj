package io.justedlev.msrv.kloudy;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.data.envers.repository.config.EnableEnversRepositories;

@SpringBootApplication
@EnableDiscoveryClient
@EnableEnversRepositories
@EnableConfigurationProperties
public class KloudyApplication {

    public static void main(String[] args) {
        SpringApplication.run(KloudyApplication.class, args);
    }

}
