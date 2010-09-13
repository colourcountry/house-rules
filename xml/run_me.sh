#!/bin/sh

if [ -z $1 ]
then
    echo "Usage: run_me.sh input (for src/input.xml)"
    exit 1
fi

rm -f scrap/*

export XML="$1"
export BASE=$(basename "$XML" .xml)
echo "$1 --> pdf/$BASE.pdf"
saxonb-xslt -o scrap/game.xml "$1" xsl/preprocess.xsl
saxonb-xslt -ext:on scrap/game.xml xsl/game.xsl

#export HEADLESS="-Dlog4j.configuration=log4j.properties -Xms768m -Xmx1024m"
export HEADLESS="-Xmx2048m"
fop -c fop.conf scrap/out.fo target/"$BASE".pdf

evince target/"$BASE".pdf

