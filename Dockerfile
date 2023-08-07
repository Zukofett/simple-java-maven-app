FROM maven:latest as builder

ARG PATCH_VERSION=${PATCH}

WORKDIR /usr/src/app

COPY pom.xml ./
COPY src/ src/


ARG PATCH_VERSION=PATCH_VERSIONARG VERSION_NUM=$(mvn help:evaluate -Dexpression=project.name | grep "^[^\[]").${PATCH_VERSION}
ARG VERSION_NUM=${$(mvn help:evaluate -Dexpression=project.name | grep "^[^\[]")}.${PATCH_VERSION}
RUN mvn versions:set -DnewVersion=${VERSION_NUM}

RUN mvn -B -DskipTests clean package

FROM maven:latest as unit-tests

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/ .

RUN nvm test

FROM openjdk:22-slim as runner

COPY --from=builder /user/src/app/target/*.jar /usr/src/app/

CMD java -jar /user/src/app/*.jar
