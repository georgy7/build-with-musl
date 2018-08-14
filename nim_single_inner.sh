#!/bin/sh
set -euo pipefail

# License: СС0.
# This is a part of the "Build with Musl" tutorial.
# https://github.com/georgy7/build-with-musl

SOURCE=$1
RESULT=$2

cd /workDir

clang --verbose -std=c11 -Os -I/nim/lib $1 -c -o $RESULT.o
clang --verbose -std=c11 -Os -I/nim/lib stdlib_system.c -c -o stdlib_system.o
#clang --verbose -std=c11 -Os -I/nim/lib stdlib_locks.c -c -o stdlib_locks.o
#clang --verbose -std=c11 -Os -I/nim/lib stdlib_sharedlist.c -c -o stdlib_sharedlist.o

# Uncomment the lines with stdlib_locks if you are using `--threads:on`.
# You may need to compile and link more files here. It depends on your code.

ld -o $RESULT \
    $RESULT.o stdlib_system.o \
    #stdlib_locks.o \
    #stdlib_sharedlist.o \
    /usr/lib/crt1.o \
    /usr/lib/crti.o \
    /usr/lib/crtn.o \
    -static -L/usr/lib -L/lib \
    -lc

strip -s $RESULT
