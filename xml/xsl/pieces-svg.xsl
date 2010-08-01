<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:attribute-set name="outline">
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">black</xsl:attribute>
        <xsl:attribute name="stroke-width">1pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fill">
        <xsl:attribute name="fill">black</xsl:attribute>
        <xsl:attribute name="stroke">black</xsl:attribute>
        <xsl:attribute name="stroke-width">1pt</xsl:attribute>
    </xsl:attribute-set>

    <!--
        Templates svg-with-* are called in mode="fo"
        and must create a new svg:svg for embedding.

        Templates svg-* are called in the same context in mode="svg"
        and should contain any SVG referenced by <use>
        tags in svg-with-*
    -->

    <xsl:template name="svg-with-player">
        <xsl:param name="colour"/>
        <svg:svg width="12pt" height="12pt">
            <svg:g transform="translate(6,6)">
                <svg:g clip-path="url(svg/pieces.svg#clip-path-player)">
                    <svg:use xlink:href="svg/pieces.svg#fill-{$colour}"/>
                </svg:g>
                <svg:use xlink:href="svg/pieces.svg#player"/>
            </svg:g>
        </svg:svg>
    </xsl:template>

    <xsl:template name="svg-with-piece">
        <xsl:param name="colour"/>
        <xsl:param name="shape"/>
        <svg:svg width="30" height="12">
            <xsl:call-template name="piece-impl">
                <xsl:with-param name="colour"><xsl:value-of select="$colour" /></xsl:with-param>
                <xsl:with-param name="shape"><xsl:value-of select="$shape" /></xsl:with-param>
                <xsl:with-param name="cy">6</xsl:with-param>
                <xsl:with-param name="cx">15</xsl:with-param>
            </xsl:call-template>
        </svg:svg>
    </xsl:template>

    <xsl:template name="get-stack-height">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-stack-height" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="count(piece)*8 + 2"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="svg-with-stack">
        <xsl:param name="height"><xsl:call-template name="get-stack-height"/></xsl:param>
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="generate-id(.)" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <svg:svg width="40" height="{$height}">
            <svg:g transform="translate(0,{$height})">
                <svg:use xlink:href="out.svg#{$id}" />
            </svg:g>
        </svg:svg>
    </xsl:template>

    <xsl:template name="svg-stack">
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="generate-id(.)" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <svg:g id="{$id}">
            <xsl:choose>
                <xsl:when test="@use">
                    <svg:use xlink:href="#{@use}" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="piece">
                        <xsl:call-template name="piece-impl">
                            <xsl:with-param name="colour"><xsl:value-of select="colour/@value" /></xsl:with-param>
                            <xsl:with-param name="shape"><xsl:value-of select="shape/@value" /></xsl:with-param>
                            <xsl:with-param name="cy"><xsl:value-of select="3 - position()*8"/></xsl:with-param>
                            <xsl:with-param name="cx">20</xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </svg:g>
    </xsl:template>

    <xsl:template name="piece-impl">
        <xsl:param name="cy">0</xsl:param>
        <xsl:param name="cx">0</xsl:param>
        <xsl:param name="colour"/>
        <xsl:param name="shape"/>
        <svg:g
            transform="translate({$cx},{$cy})">
            <svg:g clip-path="url(svg/pieces.svg#clip-path-piece-{$shape})">
                <svg:use xlink:href="svg/pieces.svg#fill-{$colour}"/>
            </svg:g>
            <svg:use xlink:href="svg/pieces.svg#piece-{$shape}"/>
        </svg:g>
    </xsl:template>

</xsl:stylesheet>
