package com.example.authorized_hello

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.Customizer
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.provisioning.InMemoryUserDetailsManager
import org.springframework.security.web.SecurityFilterChain
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder

// https://www.baeldung.com/spring-security-login
// https://docs.spring.io/spring-security/site/docs/current/api/org/springframework/security/crypto/password/PasswordEncoder.html

@Configuration
class SecurityConfig {

  @Bean
  fun userDetailsService(): InMemoryUserDetailsManager {
    val user: UserDetails = User.withUsername("premier@gov.pl")
      .password(passwordEncoder().encode("admin1"))
      .roles("ADMIN")
      .build();
    return InMemoryUserDetailsManager(user);
  }

  @Bean
  fun passwordEncoder(): PasswordEncoder { 
    return BCryptPasswordEncoder(); 
  }

  @Bean
  fun filterChain(http: HttpSecurity): SecurityFilterChain {
    http
      .csrf({ it.disable() })
      .authorizeHttpRequests({
        it.requestMatchers(
          "/login",
          "/login.html"
        ).permitAll()
        it.anyRequest().authenticated()
      }).formLogin({
        it.loginPage("/login")
        it.failureUrl("/login?error")
        it.defaultSuccessUrl("/secret/premier@gov.pl?password=admin1", true)
        it.permitAll()
      })
    return http.build()
  }

}
