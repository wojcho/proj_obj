package com.example.authorized_hello

import org.springframework.stereotype.Service

// https://www.baeldung.com/kotlin/singleton-classes
@Service
object EagerAuthorization {
  fun isAuthorized(username: String, password: String): Boolean {
    return username == "premier" && password == "admin1";
  }
}
