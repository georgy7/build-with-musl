#!/bin/sh
set -euo pipefail

# License: СС0.
# This is a part of the "Build with Musl" tutorial.
# https://github.com/georgy7/build-with-musl

SOURCE=$1
RESULT=$2

cd /workDir

clang --verbose -std=c11 -Os -I/nim-0.18.0/lib $1 -c -o $RESULT.o
clang --verbose -std=c11 -Os -I/nim-0.18.0/lib stdlib_system.c -c -o stdlib_system.o

ld -o $RESULT \
    $RESULT.o stdlib_system.o \
    /usr/lib/crt1.o \
    /usr/lib/crti.o \
    /usr/lib/crtn.o \
    -static -L/usr/lib -L/lib \
    -lc

strip -s $RESULT

# rm $RESULT.o
# rm stdlib_system.o
