#!/bin/sh

saxonb-xslt -ext:on pylon.xml xsl/game.xsl

export HEADLESS="-Dlog4j.configuration=log4j.properties"
fop out.fo pylon.pdf
evince pylon.pdf
