<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:attribute-set name="phasename">
        <xsl:attribute name="font-size">24pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">black</xsl:attribute>
        <xsl:attribute name="stroke-width">1pt</xsl:attribute>
    </xsl:attribute-set>




    <xsl:template name="phase-name">
        <xsl:param name="value" />
        <xsl:param name="width">14pt</xsl:param>
        <svg:svg width="{$width}" height="19pt">
            <!-- 
                FIXME: MAGIC NUMBERS 19 is presumably
                       fop specific, svg doesn't like "pt"
                       and the scale factor is arbitrary
            -->
            <svg:text x="0" y="18" 
                      xsl:use-attribute-sets="phasename"
                ><xsl:value-of select="$value" /></svg:text>
        </svg:svg>
    </xsl:template>

    <xsl:template name="right-arrow">
        <svg:svg width="18pt" height="18pt">
            <svg:path d="M 5 5 L 5 13 L 9 13 L 9 17 L 17 9 L 9 1 L 9 5 Z"
                      xsl:use-attribute-sets="phasename" />
        </svg:svg>
    </xsl:template>

    <xsl:template name="repeat-arrow">
        <svg:svg width="48pt" height="18pt">
            <svg:path d="M 5 5 L 5 13 L 9 13 L 9 17 L 17 9 L 9 1 L 9 5 Z"
                      xsl:use-attribute-sets="phasename" />
            <svg:path d="M 35 5 L 35 13 L 39 13 L 39 17 L 47 9 L 39 1 L 39 5 Z"
                      xsl:use-attribute-sets="phasename" />
        </svg:svg>
    </xsl:template>

</xsl:stylesheet>
