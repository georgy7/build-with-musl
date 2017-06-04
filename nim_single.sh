#!/bin/bash
set -euo pipefail

SOURCE=$1
RESULT=$2

cp nim_single_inner.sh nimcache/
cd nimcache/
docker run -v $(pwd):/workDir -it nimclangmusl /workDir/nim_single_inner.sh $1 $2
cd ..
