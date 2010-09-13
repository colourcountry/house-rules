<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:template name="svg-with-bullet">
        <svg:svg width="6pt" height="6pt">
            <svg:g fill="{$rule-colour}">
                <svg:use xlink:href="../svg/elements.svg#bullet"/>
            </svg:g>
        </svg:svg>
    </xsl:template>

    <xsl:template name="svg-with-right-arrow">
        <svg:svg width="22pt" height="18pt">
            <svg:use xlink:href="../svg/elements.svg#right-arrow"/>
        </svg:svg>
    </xsl:template>

    <xsl:template name="svg-with-crossed-right-arrow">
        <svg:svg width="22pt" height="18pt">
            <svg:use xlink:href="../svg/elements.svg#crossed-right-arrow"/>
        </svg:svg>
    </xsl:template>

    <xsl:template name="svg-with-forced-right-arrow">
        <svg:svg width="30pt" height="18pt">
            <svg:use xlink:href="../svg/elements.svg#forced-right-arrow"/>
        </svg:svg>
    </xsl:template>

    <xsl:template name="svg-with-repeat-arrow">
        <svg:svg width="40pt" height="18pt">
            <svg:use xlink:href="../svg/elements.svg#repeat-arrow"/>
        </svg:svg>
    </xsl:template>

</xsl:stylesheet>
