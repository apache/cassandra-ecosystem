#!/bin/bash
# Build the sidecar jar artifacts (no tests) from the ecosystem root.
#
# Server build uses JDK 11 by default. For the Java 8 client-only check:
#   JDK_VERSION=8 ./build_sidecar.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

JDK_VERSION="${JDK_VERSION:-11}"
export JAVA_HOME="$(/usr/libexec/java_home -v "$JDK_VERSION")"

echo "Building sidecar: JDK $JDK_VERSION"
echo "JAVA_HOME=$JAVA_HOME"

cd "$SCRIPT_DIR/sidecar"

# Build jars/artifacts only — no unit tests, no checkstyle/spotbugs.
# dtest jars are TEST-only, so a jar build doesn't need them; run
# ./scripts/build-dtest-jars.sh separately if you want to run integration tests.
# (Use `./gradlew build` or the CI workflow to run the full test suite.)
./gradlew assemble
