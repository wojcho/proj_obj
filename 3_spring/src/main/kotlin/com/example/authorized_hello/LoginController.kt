package com.example.authorized_hello

import org.springframework.security.core.Authentication
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.servlet.view.RedirectView

@Controller
class LoginController {

  @GetMapping("/login")
  fun login(): Any {
    // Checking authentication using another way, from Spring Security login, instead of using LazyAuthentication, EagerAuthentication
    val auth: Authentication? = SecurityContextHolder.getContext().authentication
    val isAuthenticated = auth != null && auth.isAuthenticated && auth.principal != "anonymousUser"
    // println("auth = $auth")
    // println("class = ${auth?.javaClass}")
    // println("authenticated = ${auth?.isAuthenticated}")
    return if (isAuthenticated) {
      RedirectView("/secret/premier@gov.pl?password=admin1", true)
    } else {
      "forward:/login.html"
    }
  }
}
