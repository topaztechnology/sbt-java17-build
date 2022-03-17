# Scala base build image

## Supported tags and respective `Dockerfile` links
`latest` [(Dockerfile)](https://github.com/topaztechnology/sbt-java17-build/blob/master/Dockerfile) - the latest release

|   Tag         | Ubuntu  | JDK      | Scala 2.13 |  SBT     | Dockerfile |
|---------------|---------|----------|------------|----------|------------|
| `17.0.3`      | `20.04` | `17.0.3` | `2.13.8`   | `1.6.2`  | [(Dockerfile)](https://github.com/topaztechnology/sbt-java17-build/blob/17.0.3/Dockerfile) |

## Overview

A simple base image to be used in multistage Docker builds for Scala projects, including JDK 17 and SBT. The build also caches specific versions of Scala & SBT to improve image build time.
