#! /bin/bash

# Generate a local.properties file sufficient to build and run Android unit tests.
# Run from project root directory.
echo "FSOrgId=TEST" > example/android/local.properties
FLUTTER_BIN=$(dirname "$(which flutter)")
echo "flutter.sdk=$FLUTTER_BIN/.." >> example/android/local.properties
