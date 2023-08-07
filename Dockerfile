FROM maven:latest as builder

ARG PATCH_VERSION=${PATCH}

WORKDIR /usr/src/app

COPY pom.xml ./
COPY src/ src/


ARG VERSION_NUM=${PATCH_VERSION}
RUN mvn versions:set -DnewVersion=${VERSION_NUM}

RUN mvn -B -DskipTests clean package

FROM maven:latest as unit-tests

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/ .

RUN nvm test

FROM openjdk:22-slim as runner

COPY --from=builder target/*.jar ./

CMD java -jar ./*.jar
