#! /bin/bash

# Generate a local.properties file sufficient to build and run Android unit tests.
mkdir -p ~/.gradle
echo "FSOrgId=TEST" > ~/.gradle/gradle.properties
FLUTTER_BIN=$(dirname "$(which flutter)")
echo "flutter.sdk=$FLUTTER_BIN"/.. >> ~/.gradle/gradle.properties