#!/bin/sh

if [ -z $1 ]
then
    echo "Usage: run_me.sh input.xml"
    exit 1
fi

export XML="$1"
export BASE=$(basename "$XML" .xml)
echo "$BASE.xml --> $BASE.pdf"
saxonb-xslt -ext:on "$BASE.xml" xsl/game.xsl

export HEADLESS="-Dlog4j.configuration=log4j.properties"
fop out.fo "$BASE".pdf

evince "$BASE".pdf

