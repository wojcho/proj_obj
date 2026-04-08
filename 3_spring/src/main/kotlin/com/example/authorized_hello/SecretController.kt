package com.example.authorized_hello

import java.util.concurrent.atomic.AtomicLong

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RestController

private val userHelloSecrets = mapOf("premier" to "admin1")

@RestController
class SecretController {

  private val counter = AtomicLong()

  @GetMapping("/secret/{username}")
  fun secret(@PathVariable("username") username: String): Hello {
    val secretOfUser = userHelloSecrets[username] ?: throw IllegalArgumentException("Unrecognized username")
    return Hello(counter.incrementAndGet(), secretOfUser)
  }

}
