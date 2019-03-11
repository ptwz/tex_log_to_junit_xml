#!/bin/bash

me=`readlink -f "$0"`
scriptdir=`dirname "$me"`

filebase=`basename "$1" .tex`

latexmk -silent --lualatex -gg "$1" 
retcode=$?

awk -f "$scriptdir/preprocess.awk" "$filebase.log" | awk -f "$scriptdir/parselog.awk" | awk -f "$scriptdir/log2junitxml.awk" > "$filebase"-result.xml

exit $?
