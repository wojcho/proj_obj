// https://www.baeldung.com/kotlin/singleton-classes
object EagerAuthorization {
  fun isAuthorized(username: String, password: String): Boolean {
    return username == "premier" && password == "admin1";
  }
}
