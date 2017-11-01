#!/bin/bash

scripts/generate_swagger_spec.sh local static/swagger

mvn -f codegen/pom.xml package

java -cp codegen/target/static-html-codegen-1.0.0.jar:$(brew --prefix swagger-codegen)/libexec/swagger-codegen-cli.jar io.swagger.codegen.Codegen -i static/swagger/swagger.json -c config/strava-html.json -l strava-html -o content/docs

hugo server --port=1313 --baseURL=http://localhost:1313 --bind 0.0.0.0 --watch=true --disableRSS --disableSitemap
