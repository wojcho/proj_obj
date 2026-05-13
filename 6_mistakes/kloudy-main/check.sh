./codeql/codeql database create codeql-db --language=java --command="mvn clean compile -DskipTests" --source-root=. --overwrite
./codeql/codeql database analyze codeql-db codeql/java-queries:codeql-suites/java-security-extended.qls --format=sarif-latest --output=results.sarif
