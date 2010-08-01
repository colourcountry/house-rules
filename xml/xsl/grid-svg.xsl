<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:attribute-set name="grid-line">
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">black</xsl:attribute>
        <xsl:attribute name="stroke-width">1pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="grid-border">
        <xsl:attribute name="fill">#cccccc</xsl:attribute>
        <xsl:attribute name="stroke">none</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="grid-background">
        <xsl:attribute name="fill">#ffffff</xsl:attribute>
        <xsl:attribute name="stroke">none</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template name="get-grid-height">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-grid-height" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@rows * 36 + 20" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-grid-width">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-grid-width" />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@columns * 36 + 20" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="svg-with-grid">
        <xsl:param name="scale">0.7</xsl:param>
        <xsl:variable name="height"><xsl:call-template name="get-grid-height"/></xsl:variable>
        <xsl:variable name="width"><xsl:call-template name="get-grid-width"/></xsl:variable>
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
                <xsl:otherwise>--<xsl:value-of select="generate-id(.)" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <svg:svg width="{$width * $scale}" height="{$height * $scale}">
            <svg:g transform="scale({$scale})">
                <svg:use xlink:href="out.svg#{$id}" />
            </svg:g>
        </svg:svg>
    </xsl:template>

    <xsl:template name="svg-grid">
        <xsl:variable name="height"><xsl:call-template name="get-grid-height"/></xsl:variable>
        <xsl:variable name="width"><xsl:call-template name="get-grid-width"/></xsl:variable>
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
                <xsl:otherwise>--<xsl:value-of select="generate-id(.)" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <svg:g id="{$id}">
            <xsl:choose>
                <xsl:when test="@use">
                    <svg:use xlink:href="#{@use}" />
                </xsl:when>
                <xsl:otherwise>
                    <svg:rect x="0" y="0" width="{$width}" height="{$height}"
                              xsl:use-attribute-sets="grid-background" />
                    <xsl:call-template name="grid-warp">
                        <xsl:with-param name="x"><xsl:value-of select="@columns" /></xsl:with-param>
                        <xsl:with-param name="height"><xsl:value-of select="$height" /></xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="grid-weft">
                        <xsl:with-param name="y"><xsl:value-of select="@rows" /></xsl:with-param>
                        <xsl:with-param name="width"><xsl:value-of select="$width" /></xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="@right='edge'">
                        <svg:rect x="{$width - 9.5}" y="0"
                                  width="9.5" height="{$height}"
                                  xsl:use-attribute-sets="grid-border" />
                    </xsl:if>
                    <xsl:if test="@left='edge'">
                        <svg:rect x="0" y="0"
                                  width="9.5" height="{$height}"
                                  xsl:use-attribute-sets="grid-border" />
                    </xsl:if>
                    <xsl:if test="@bottom='edge'">
                        <svg:rect x="0" y="{$height - 9.5}"
                                  width="{$width}" height="9.5"
                                  xsl:use-attribute-sets="grid-border" />
                    </xsl:if>
                    <xsl:if test="@top='edge'">
                        <svg:rect x="0" y="0"
                                  width="{$width}" height="9.5"
                                  xsl:use-attribute-sets="grid-border" />
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="svg"/>
        </svg:g>
    </xsl:template>

    <xsl:template match="square" mode="svg">
        <svg:g transform="translate({@x * 36 + 8},{@y * 36 + 45})">
            <xsl:apply-templates mode="svg"/>
        </svg:g>
    </xsl:template>

    <xsl:template name="grid-warp">
        <xsl:param name="x"/>
        <xsl:param name="height"/>
        <xsl:if test="$x >= 0">
            <svg:path xsl:use-attribute-sets="grid-line">
                <xsl:attribute name="d">
                    M <xsl:value-of select="$x * 36 + 10"/> 0 l 0 <xsl:value-of select="$height" />
                </xsl:attribute>
            </svg:path>
            <xsl:call-template name="grid-warp">
                <xsl:with-param name="x"><xsl:value-of select="$x - 1" /></xsl:with-param>
                <xsl:with-param name="height"><xsl:value-of select="$height" /></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="grid-weft">
        <xsl:param name="y"/>
        <xsl:param name="width"/>
        <xsl:if test="$y >= 0">
            <svg:path xsl:use-attribute-sets="grid-line">
                <xsl:attribute name="d">
                    M 0 <xsl:value-of select="$y * 36 + 10"/> l <xsl:value-of select="$width" /> 0
                </xsl:attribute>
            </svg:path>
            <xsl:call-template name="grid-weft">
                <xsl:with-param name="y"><xsl:value-of select="$y - 1" /></xsl:with-param>
                <xsl:with-param name="width"><xsl:value-of select="$width" /></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
