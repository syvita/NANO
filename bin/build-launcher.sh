#!/bin/bash
set -e
set -o pipefail

if [ $(uname -s) = Darwin ]; then
    basedir=$(dirname $(cd "$(dirname "$0")"; pwd -P))
else
    basedir=$(dirname $(dirname $(readlink -fm $0)))
fi

source "$basedir/bin/java-config.sh"

echo "*** Compiling CLI"
"$JAVA_HOME"/bin/javac --module-path "$basedir/target/modules/combined.jar" -d "$basedir/target/classes/org.syvita.i2p.nano" $(find "$basedir/org.syvita.i2p.nano/src" -name '*.java')
cp "$basedir/org.syvita.i2p.nano/src/org/syvita/i2p/nano/VERSION" "$basedir/target/classes/org.syvita.i2p.nano/org/syvita/i2p/nano/"

echo "*** Packaging CLI as a modular jar"
"$JAVA_HOME"/bin/jar --create --file "$basedir/target/org.syvita.i2p.nano.jar" --main-class org.syvita.i2p.nano.Main -C "$basedir/target/classes/org.syvita.i2p.nano" .
normalizeZip "$basedir/target/org.syvita.i2p.nano.jar"

# create OS specific launchers which will bundle together the code and a minimal JVM
for i in ${TARGETS}; do
  echo "*** Performing jlink ($i)"

  JAVA_HOME_VARIANT=$basedir/import/jdks/${i}/${variables["JAVA_HOME_$i"]}
  echo "Using JAVA_HOME_VARIANT: $JAVA_HOME_VARIANT"
  "$JAVA_HOME"/bin/jlink --module-path "${JAVA_HOME_VARIANT}/jmods":"$basedir/target/modules":"$basedir/target/org.syvita.i2p.nano.jar" --add-modules combined,org.syvita.i2p.nano --output "$basedir/dist/$i/router" --compress 2 --no-header-files --no-man-pages --order-resources=**/module-info.class,/java.base/java/lang/**,**javafx**
done

for target in ${TARGETS}; do
  cp -r "$basedir/import/i2p.base" "$basedir/dist/$target/router/";
done

# remove unnecessary native libs from jbigi.jar
for i in ${TARGETS}; do
  for j in freebsd linux mac win; do
    if [ "$i" != "$j" ]; then
      if [ "$j" = "mac" ]; then j="osx"; fi
      if [ "$j" = "win" ]; then j="windows"; fi
      zip -d "$basedir/dist/$i/router/i2p.base/jbigi.jar" *-${j}-*
      normalizeZip "$basedir/dist/$i/router/i2p.base/jbigi.jar"
      fi
  done
done

# build linux structure
if [[ "$TARGETS" =~ "linux" ]]; then
  mv "$basedir/dist/linux/router" "$basedir/dist/linux/router-tmp"
  mkdir -p "$basedir/dist/linux/router/bin"
  mkdir -p "$basedir/dist/linux/router/lib"
  cp "$basedir/import/jpackage/linux/classes/jdk/incubator/jpackage/internal/resources/jpackageapplauncher" "$basedir/dist/linux/router/bin/i2p-zero"
  chmod +x "$basedir/dist/linux/router/bin/i2p-zero"
  mkdir -p "$basedir/dist/linux/router/lib/app"
  cp "$basedir/resources/i2p-zero.linux.cfg" "$basedir/dist/linux/router/lib/app/i2p-zero.cfg"
  mv "$basedir/dist/linux/router-tmp" "$basedir/dist/linux/router/lib/runtime"
  cp "$basedir/import/jpackage/linux/classes/jdk/incubator/jpackage/internal/resources/libapplauncher.so" "$basedir/dist/linux/router/lib/"
fi


# build win structure
if [[ "$TARGETS" =~ "win" ]]; then
  mv "$basedir/dist/win/router" "$basedir/dist/win/router-tmp"
  mkdir -p "$basedir/dist/win/router/app"
  cp "$basedir/resources/i2p-zero.win.cfg" "$basedir/dist/win/router/app/i2p-zero.cfg"
  mv "$basedir/dist/win/router-tmp" "$basedir/dist/win/router/runtime"
  cp "$basedir/resources/launch.bat" "$basedir/dist/win/router/launch.bat"
  cp "$basedir/import/jpackage/win/classes/jdk/incubator/jpackage/internal/resources/applauncher.dll" "$basedir/dist/win/router/"
fi

for i in ${TARGETS}; do
  if [ ${i} != "win" ]; then
    cp "$basedir/resources/tunnel-control.sh" "$basedir/dist/$i/router/bin/"
  fi
done

if [[ "$TARGETS" =~ "mac" ]]; then
  cp "$basedir/resources/launch.sh" "$basedir/dist/mac/router/bin/"
fi

# show distribution sizes
du -sk "$basedir/dist/"* | awk '{printf "%.1f MB %s\n",$1/1024,$2}'


echo "*** Done ***"
echo "To build the distribution archives and show reproducible build SHA-256 hashes, type: bin/zip-all.sh"
echo ""
