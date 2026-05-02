#!/bin/sh
DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$DIR" || exit 1
./dosbox/dosbox -noprimaryconf -nolocalconf -conf dosbox.conf -exit
