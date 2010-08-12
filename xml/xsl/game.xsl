<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:include href="game-fo.xsl" />
    <xsl:include href="game-svg.xsl" />
    <xsl:include href="pieces-svg.xsl" />
    <xsl:include href="elements-svg.xsl" />
    <xsl:include href="grid-svg.xsl" />

    <xsl:output method="xml"/>

    <xsl:template match="/">
        <xsl:result-document href="scrap/out.svg"
                             indent="yes">
            <xsl:apply-templates select="." mode="svg"/>
        </xsl:result-document>
        <xsl:result-document href="scrap/out.fo"
                             indent="yes">
            <xsl:apply-templates select="." mode="fo"/>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
