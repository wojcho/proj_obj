**Zadanie 6** Code Smells

Należy sprawdzić kod projektów.
Aby uzyskać ocenę 3.0, 3.5, 4.0 wystarczy sam JavaScript.
Aby uzyskać ocenę 4.5, 5.0 konieczny jest sprawdzić JavaScript, Kotlin, Go.
(Powyższa część polecenia została doprecyzowana zgodnie z tym w jaki sposób została zinterpretowana podczas rozwiązywania.)

- :white_check_mark: 3.0 Należy skonfigurować husky + lint-staged uruchamianie lintowania przed commitem [Commit](https://github.com/wojcho/e_biznes/commit/e31d8763ab3d104b8aff9866e71ca5d08ffc96ac)
- :white_check_mark: 3.5 Należy wyeliminować wszystkie bugi w kodzie w Sonarze (kod aplikacji klienckiej) [Commit](https://github.com/wojcho/e_biznes/commit/bea5e21e0a1fa6febe21779468b0762ac2fc2a09)
- :white_check_mark: 4.0 Przeskanować oraz naprawić dowolny projekt open source narzędziem [CodeQL](https://codeql.github.com/) [Commit](https://github.com/wojcho/proj_obj/commit/f0094e8d8f527821424ed95dd70cfe4bb6547bc7)
- :white_check_mark: 4.5 Należy usunąć problemy typu code smell w kodzie w Sonarze (Kotlin[![Code Smells](http://localhost:9000/api/project_badges/measure?project=ktor&metric=code_smells&token=sqb_a794b03a807c7cb0f96fa9a3a7f0e79865762fa1)](http://localhost:9000/dashboard?id=ktor), Go [![Code Smells](http://localhost:9000/api/project_badges/measure?project=shop&metric=code_smells&token=sqb_7701013d4762bee87c4bd01ab7ee5b6f6f64daf3)](http://localhost:9000/dashboard?id=shop), JavaScript [![Code Smells](http://localhost:9000/api/project_badges/measure?project=frontend&metric=code_smells&token=sqb_77044f9bcd7d2f5b23bf972dd1e02093fed56995)](http://localhost:9000/dashboard?id=frontend)). Należy dodać badge z Sonara [Rendered badges SVG (it used SonarQube at localhost)](https://github.com/wojcho/proj_obj/blob/main/6_mistakes/badges.pdf) [Commit](https://github.com/wojcho/e_biznes/commit/db1511938a340542640e705ed6be01d6493ec8d3)
- :white_check_mark: 5.0 Skonfigurować Github Actions z linterem oraz CodeQL [Commit](https://github.com/wojcho/e_biznes/commit/fceab188e1597acdba5fd906acc8b3deeb216fb8) [Commit](https://github.com/wojcho/e_biznes/commit/52d8f2aa175434937e229e9f0edaed6fc70c52b0)

[Nagranie CodeQL](https://github.com/wojcho/proj_obj/blob/main/6_mistakes/codeql_video.mp4)
[Nagranie Sonar JavaScript](https://github.com/wojcho/proj_obj/blob/main/6_mistakes/sonar_video.mp4)
[Nagranie Sonar Kotlin Go JavaScript](https://github.com/wojcho/proj_obj/blob/main/6_mistakes/sonar_video_kotlin_go_js.mp4)
[Nagranie Github Actions](https://github.com/wojcho/proj_obj/blob/main/6_mistakes/github_actions_video.mp4)
