#!/bin/bash
# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.
#
# get the directory of this script so we can execute the related python
# http://stackoverflow.com/a/246128/212110
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  BASEDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$BASEDIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
BASEDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

for opt in "$@"; do
  if [ "$opt" == "--debug" ]; then
    echo "Executing from '$BASEDIR'"
  fi
done

# we need to handle the --help option outside the python
# flow since otherwise we will move into input selection...
for opt in "$@"; do
  if [ "$opt" == "--help" -o "$opt" == "-h" ]; then
    python "$BASEDIR/src/printHelp.py"
    exit 0
  fi
done

# process input from pipe and store as pickled file
python "$BASEDIR/src/processInput.py"
# now choose input and...
exec 0<&-
python "$BASEDIR/src/choose.py" < /dev/tty
# execute the output bash script
sh ~/.fbPager.sh < /dev/tty
