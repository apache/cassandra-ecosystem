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
# assemble still compiles test-common's test fixtures against one in-jvm dtest jar
# (Cassandra 4.1), so build that one first (network; the script re-clones Cassandra but
# skips the build when the jar exists). The JDK 8 client-only build doesn't include
# test-common. Run ./scripts/build-dtest-jars.sh without BRANCHES for the full set that
# integration tests need.
# (Use `./gradlew build` or the CI workflow to run the full test suite.)
if [ "$JDK_VERSION" != "8" ]; then
  BRANCHES="${BRANCHES:-cassandra-4.1}" ./scripts/build-dtest-jars.sh
fi
./gradlew assemble
