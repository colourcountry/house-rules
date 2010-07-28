#!/bin/sh

xsltproc -o pylon.fo xsl/game-fo.xsl pylon.xml
fop pylon.fo pylon.pdf
evince pylon.pdf
