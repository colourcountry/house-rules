#!/bin/sh

xsltproc -o pylon.fo game-fo.xsl pylon.xml
fop pylon.fo pylon.pdf
evince pylon.pdf
