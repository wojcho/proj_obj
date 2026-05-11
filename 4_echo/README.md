**Zadanie 4** Wzorce strukturalne, Echo (Go)

Należy stworzyć aplikację w Go na frameworku echo.
Aplikacja ma mieć jeden endpoint, minimum jedną funkcję proxy, która pobiera dane np. o pogodzie, giełdzie, etc. (do wyboru) z zewnętrznego API.
Zapytania do endpointu można wysyłać w jako GET lub POST.

- :white_check_mark: 3.0 Należy stworzyć aplikację we frameworki echo w j. Go, która będzie miała kontroler Pogody, która pozwala na pobieranie danych o pogodzie (lub akcjach giełdowych) [Commit](https://github.com/wojcho/proj_obj/commit/e2b8cbeeb7d50176d2eb0d226625d18e0e9cfcf6)
- :white_check_mark: 3.5 Należy stworzyć model Pogoda (lub Giełda) wykorzystując gorm, a dane załadować z listy przy uruchomieniu [Commit](https://github.com/wojcho/proj_obj/commit/e2b8cbeeb7d50176d2eb0d226625d18e0e9cfcf6)
- :white_check_mark: 4.0 Należy stworzyć klasę proxy, która pobierze dane z serwisu zewnętrznego podczas zapytania do naszego kontrolera [Commit](https://github.com/wojcho/proj_obj/commit/8d119f0681fd266f6925dd9a16556c53da4553c6)
- :white_check_mark: 4.5 Należy zapisać pobrane dane z zewnątrz do bazy danych [Commit](https://github.com/wojcho/proj_obj/commit/3e59f7118425fa0e45ebc8b2e17ca4958eb5e8e0)
- :white_check_mark: 5.0 Należy rozszerzyć endpoint na więcej niż jedną lokalizację (Pogoda), lub akcje (Giełda) zwracając JSONa [Commit](https://github.com/wojcho/proj_obj/commit/b667250ca2fd1196bf8a52b0e777f666459d4e2a)

[Nagranie](https://github.com/wojcho/proj_obj/blob/main/4_echo/video.mp4)
