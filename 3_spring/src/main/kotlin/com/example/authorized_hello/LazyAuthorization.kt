package com.example.authorized_hello

import org.springframework.stereotype.Service

// https://www.baeldung.com/kotlin/singleton-classes#3-lazy-initialization
@Service
class LazyAuthorization {
  companion object {
    val instance: LazyAuthorization by lazy {
      LazyAuthorization()
    }
  }
  fun isAuthorized(username: String, password: String): Boolean {
    return username == "premier" && password == "admin1";
  }
}
