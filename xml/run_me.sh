#!/bin/sh

if [ -z $1 ]
then
    echo "Usage: run_me.sh input (for src/input.xml)"
    exit 1
fi

export XML="$1"
export BASE=$(basename "$XML" .xml)
echo "$1 --> pdf/$BASE.pdf"
saxonb-xslt -ext:on "$1" xsl/game.xsl

export HEADLESS="-Dlog4j.configuration=log4j.properties"
fop scrap/out.fo target/"$BASE".pdf

evince target/"$BASE".pdf

