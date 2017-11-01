# Developers.strava.com (β)

This code contains the sources needed to generate the content of [developers.strava.com](https://developers.strava.com).

Specifically, this repository implements a [Hugo](https://gohugo.io) static website, whose content is pre-generated from a set of [Swagger](swagger.io) definitions that describe the Strava API. Swagger is an open-source set of tools that aim to facilitate the management of REST APIs by:

- Defining a specification for describing API endpoints (URL, method, parameters, etc…)
- Implementing a subset of the JSON-Schema specification that enables describing the models (i.e.
  the payloads) that the API consumes and returns.

This model enables anyone to generate up-to-date, working client libraries for the Strava API and matching documentation. As such, this repository serves two purposes:

- Be the source of truth for endpoints and models exposed by the Strava API.
- Be a place of exchange for external developers to continuously provide feedback, track bugs and
feature requests and (optionally) contribute back.

From these, we intend to provide developers with a better support and tighter feedback loop with the Strava engineering team, as well as a place of exchange for the community of developers using the Strava API.

## Compiling and running the site

We rely on [Docker](https://www.docker.com/) to build and run the site. Download and install Docker for your machine and then build and run the image:

    $ docker build --rm -t strava/developers.strava.com .
    $ docker run -p 1313:1313 strava/developers.strava.com:latest

## Generation of code and documentation

### Local development

You can run this bash script to generate the local configuration, client code, and documentation:

    $ bash scripts/deploy_local_changes_p1313.sh
    
You can then point your browser to [localhost:1313](localhost:1313) to see your current branch on a local server. If the deploy script doesn't work for you, continue to the next sections; they describe in more detail each one of the script's processes. 

### [Optional] Generating the local configuration

The OpenAPI specification maintained in this repository, along with the various models it refers to, are not checked-in in their final form. In some cases, such as in production, we want to publish a specification where all files use absolute `$ref` values. In other cases, such as when you want to work on the spec locally, files may use relative references.

If you seek to make local changes to the the API specification you will first need to generate it all. Templates are defined in [Mustache](https://mustache.github.io/), which you may need to install first. On macOS, you may use Homebrew:

    $ brew install mustache

Generating the specification and models then boils down to invoking the `generate_swagger_spec.sh` script:

    $ scripts/generate_swagger_spec.sh local static/swagger

### Client code

You will need to have a Java runtime installed on your machine to run Swagger. To generate client code, you first need to install Swagger. On macOS, you may use Homebrew:

    $ brew install swagger-codegen maven mustache

To generate code in a given language, run `swagger-codegen generate` and pass the following
parameters:

- `--input-spec <spec file>`: this may be `https://developers.strava.com/swagger/swagger.json` or `static/swagger/swagger.json` if you want the bleeding edge. If you seek to make local changes to the specification, please refer to the section above this one ('Generating the local configuration').
- `--config <configuration file>`: pass the settings or overrides you want the code generator to honor. The overrides defined by Strava are in the `config/` directory.
- `--lang <language>`: the target programming language you seek to generate code for (running `swagger-codegen` by itself will print a list of available languages)
- `--output <output directory>`: where to write the resulting files.

For instance:

    $ swagger-codegen generate -i https://developers.strava.com/swagger/swagger.json -c config/android.json -l java -o generated/java

The above will generate Java code suitable to be packaged in an Android library.

### Generating documentation

For the documentation, you need to further install `maven` – on macOS: `brew install maven`. You then need to package the generator:

    $ mvn -f codegen/pom.xml package

After that, you need to run the `io.swagger.codegen.Codegen` class and make sure the compiled package as well as the Swagger CLI is on the classpath — on macOS, this can be done as such:

    $ java -cp codegen/target/static-html-codegen-1.0.0.jar:$(brew --prefix swagger-codegen)/libexec/swagger-codegen-cli.jar io.swagger.codegen.Codegen -i static/swagger/swagger.json -c config/strava-html.json -l strava-html -o content/docs

This will generate the documentation in the location expected by the site.

## Content & Organization

This repository largely follows the [general layout](https://gohugo.io/overview/source-directory/) of a Hugo site.

### Swagger definitions

The models and endpoints of the Strava API are defined as Mustache/Swagger files stored in the `swagger/` directory and generated by default in `static/swagger` — this structure is exposed externally and therefore should be present when the site is being deployed.

### Documentation generator

The custom code generator for the API documentation is defined as a Maven project in the `codegen` directory.
