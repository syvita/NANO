#!/bin/bash

if [ $(uname -s) = Darwin ]; then
    basedir=$(dirname $(cd "$(dirname "$0")"; pwd -P))
else
    basedir=$(dirname $(dirname $(readlink -fm $0)))
fi

"$basedir"/bin/java --enable-preview -cp "$basedir/i2p.base/jbigi.jar" -m org.syvita.i2p.nano
