#!/bin/bash
set -euo pipefail

# Written in 2017 by Georgy Ustinov.
# License: СС0.
# http://creativecommons.org/publicdomain/zero/1.0/
#
# This is a part of the Build with Musl tutorial.
# https://github.com/georgy7/build-with-musl

SOURCE=$1
RESULT=$2

cp nim_single_inner.sh nimcache/
cd nimcache/
docker run -v $(pwd):/workDir -it nimclangmusl /workDir/nim_single_inner.sh $1 $2
cd ..
