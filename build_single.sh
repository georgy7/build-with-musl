#!/bin/sh
set -euo pipefail

# Written in 2017 by Georgy Ustinov.
# License: СС0.
# http://creativecommons.org/publicdomain/zero/1.0/
#
# This is a part of the Build with Musl tutorial.
# https://github.com/georgy7/build-with-musl

SOURCE=$1
RESULT=$2

cd /workDir

clang --verbose -std=c11 $1 -c -o $RESULT.o

echo -----------------

ld -o $RESULT \
    $RESULT.o \
    /usr/lib/crt1.o \
    /usr/lib/crti.o \
    /usr/lib/crtn.o \
    -static -L/usr/lib -L/lib \
    -lc

rm $RESULT.o
