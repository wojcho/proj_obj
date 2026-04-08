package com.example.authorized_hello

import java.util.concurrent.atomic.AtomicLong

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.server.ResponseStatusException
import org.springframework.http.HttpStatus

private val userHelloSecrets = mapOf("premier" to "Handling of this information requires utmost secrecy")

@RestController
class SecretController {

  private val counter = AtomicLong()

  @GetMapping("/secret/{username}")
  fun secret(@PathVariable("username") username: String, @RequestParam("password") password: String): Hello {
    val secretOfUser = userHelloSecrets[username] ?: throw ResponseStatusException(HttpStatus.UNAUTHORIZED, "Unrecognized username")
    if (!EagerAuthorization.isAuthorized(username, password)) {
      throw ResponseStatusException(HttpStatus.BAD_REQUEST, "Credentials mismatch")
    }
    return Hello(counter.incrementAndGet(), secretOfUser)
  }

}
