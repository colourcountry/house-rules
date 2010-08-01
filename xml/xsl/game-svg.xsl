<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:template match="text()" mode="svg" />

    <xsl:template match="/" mode="svg">
        <svg:svg>
            <xsl:apply-templates mode="svg"/>
        </svg:svg>
    </xsl:template>

    <xsl:template match="stack" mode="svg">
        <xsl:call-template name="svg-stack"/>
    </xsl:template>

    <xsl:template match="grid" mode="svg">
        <xsl:call-template name="svg-grid"/>
    </xsl:template>

</xsl:stylesheet>
