**Zadanie 3** Wzorce kreacyjne, Spring Boot (Kotlin)
Proszę stworzyć prosty serwis do autoryzacji, który zasymuluje autoryzację użytkownika za pomocą przesłanej nazwy użytkownika oraz hasła. Serwis powinien zostać wstrzyknięty do kontrolera (4.5).
Aplikacja ma oczywiście zawierać jeden kontroler i powinna zostać napisana w języku Kotlin.
Oparta powinna zostać na frameworku Spring Boot.
Serwis do autoryzacji powinien być singletonem.

- :white_check_mark: 3.0 Należy stworzyć jeden kontroler wraz z danymi wyświetlanymi z listy na endpoincie w formacie JSON - Kotlin + Spring Boot [Commit](https://github.com/wojcho/proj_obj/commit/ee7733665dd58b4c1d95ae4687c59637368ec9be)
- :white_check_mark: 3.5 Należy stworzyć klasę do autoryzacji (mock) jako Singleton w formie Eager <!-- [Commit]() -->
- :x: <!-- :white_check_mark: --> 4.0 Należy obsłużyć dane autoryzacji przekazywane przez użytkownika <!-- [Commit]() -->
- :x: <!-- :white_check_mark: --> 4.5 Należy wstrzyknąć singleton do głównej klasy via @Autowired lub konstruktor (constructor injection) <!-- [Commit]() -->
- :x: <!-- :white_check_mark: --> 5.0 Obok wersji Eager do wyboru powinna być wersja Singletona w wersji Lazy <!-- [Commit]() -->

<!-- [Nagranie]() -->

<!-- https://spring.io/guides/gs/rest-service -->
<!-- Create a Resource Representation Class -->
