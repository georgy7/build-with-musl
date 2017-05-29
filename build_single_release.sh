#!/bin/sh
set -euo pipefail

SOURCE=$1
RESULT=$2

cd /workDir

clang --verbose -std=c11 -pie $1 -c -o $RESULT.o

echo -----------------

ld -o $RESULT \
    $RESULT.o \
    /usr/lib/crt1.o \
    /usr/lib/crti.o \
    /usr/lib/crtn.o \
    -strip-all \
    -static -L/usr/lib -L/lib \
    -lc

rm $RESULT.o
