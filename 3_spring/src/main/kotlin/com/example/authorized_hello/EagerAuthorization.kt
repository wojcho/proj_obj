package com.example.authorized_hello

import org.springframework.stereotype.Component

// https://www.baeldung.com/kotlin/singleton-classes
@Component
object EagerAuthorization {
  fun isAuthorized(username: String, password: String): Boolean {
    return username == "premier" && password == "admin1";
  }
}
