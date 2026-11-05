#!/bin/bash
# Build the analytics jar artifacts (no tests) from the ecosystem root.
#
# Profile defaults to Spark 3 / Scala 2.12 / JDK 11. Override by pre-setting the
# env vars, e.g. the Spark 4 / Scala 2.13 / JDK 17 variant:
#   JDK_VERSION=17 SPARK_VERSION=4 SCALA_VERSION=2.13 ./build_analytics.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

JDK_VERSION="${JDK_VERSION:-11}"
SPARK_VERSION="${SPARK_VERSION:-3}"
SCALA_VERSION="${SCALA_VERSION:-2.12}"
export JAVA_HOME="$(/usr/libexec/java_home -v "$JDK_VERSION")"
export JDK_VERSION SPARK_VERSION SCALA_VERSION

# JDK 17 targets Cassandra 5.0 only; skip the 4.0/4.1 dtest jar builds.
if [ "$JDK_VERSION" = "17" ]; then
  export BRANCHES="${BRANCHES:-cassandra-5.0}"
fi

echo "Building analytics: JDK $JDK_VERSION, Spark $SPARK_VERSION, Scala $SCALA_VERSION"
echo "JAVA_HOME=$JAVA_HOME"

cd "$SCRIPT_DIR/analytics"

# Build dependency jars first (needed once to compile the bridge layer; network required).
./scripts/build-dependencies.sh

# Build jars/artifacts only — no unit tests, no checkstyle/rat/spotbugs.
# (Use `./gradlew check` or the CI workflow to run the test + static-analysis suite.)
./gradlew assemble
