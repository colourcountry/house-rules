<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:attribute-set name="grid-line">
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">black</xsl:attribute>
        <xsl:attribute name="stroke-width">0.5pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="arrow">
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">#0000cc</xsl:attribute>
        <xsl:attribute name="marker-end">url(../svg/grid.svg#marker-arrow)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="callout">
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke"><xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="callout-point">
        <xsl:attribute name="stroke">none</xsl:attribute>
        <xsl:attribute name="fill"><xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="callout-box">
        <xsl:attribute name="fill">white</xsl:attribute>
        <xsl:attribute name="stroke"><xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="grid-background">
        <xsl:attribute name="fill">#ffffff</xsl:attribute>
        <xsl:attribute name="stroke">none</xsl:attribute>
    </xsl:attribute-set>

    <xsl:variable name="grid-border-fraction"><xsl:value-of select="8"/></xsl:variable>

    <xsl:template name="get-grid-height">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-grid-height" />
                </xsl:for-each>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="size">
                    <xsl:choose>
                        <xsl:when test="@size='small'">0.5</xsl:when>
                        <xsl:when test="@size='medium'">0.75</xsl:when>
                        <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="(@rows + 2) * 36 * $size + (72 * $size) div $grid-border-fraction" />
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
                <xsl:variable name="size">
                    <xsl:choose>
                        <xsl:when test="@size='small'">0.5</xsl:when>
                        <xsl:when test="@size='medium'">0.75</xsl:when>
                        <xsl:when test="@size"><xsl:value-of select="@size"/></xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="(@rows + 2) * 36 * $size + (72 * $size) div $grid-border-fraction" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-grid-size">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-grid-size" />
                </xsl:for-each>                
            </xsl:when>
            <xsl:when test="@size='small'">18</xsl:when>
            <xsl:when test="@size='medium'">24</xsl:when>
            <xsl:when test="@size"><xsl:value-of select="36 * @size"/></xsl:when>
            <xsl:otherwise>36</xsl:otherwise>
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

    <xsl:template name="grid-attributes">
        <xsl:param name="name" />
        <xsl:choose>
            <xsl:when test="$name='edge'">
                <xsl:attribute name="fill">#000000</xsl:attribute>
                <xsl:attribute name="stroke">none</xsl:attribute>
                <xsl:attribute name="stroke-width">2pt</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="fill">#000000</xsl:attribute>
                <xsl:attribute name="stroke">none</xsl:attribute>
                <xsl:attribute name="stroke-width">2pt</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="svg-grid">
        <xsl:variable name="height"><xsl:call-template name="get-grid-height"/></xsl:variable>
        <xsl:variable name="width"><xsl:call-template name="get-grid-width"/></xsl:variable>
        <xsl:variable name="size"><xsl:call-template name="get-grid-size"/></xsl:variable>
        <xsl:variable name="border-thickness"><xsl:value-of select="$size div $grid-border-fraction"/></xsl:variable>
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
                <xsl:otherwise>--<xsl:value-of select="generate-id(.)" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <svg:rect x="{$size}" y="{$size}" width="{$width}" height="{$height}"
                         xsl:use-attribute-sets="grid-background" />
        <svg:g id="{$id}" transform="translate({$size},{$size})">
            <xsl:for-each select="square">
                <svg:g transform="translate({(@x + 0.5) * $size},{(@y + 0.5) * $size})">
                    <xsl:apply-templates mode="svg-below">
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                    </xsl:apply-templates>
                </svg:g>
            </xsl:for-each>
            <xsl:for-each select="square">
                <svg:g transform="translate({(@x + 0.5) * $size},{(@y + 0.5) * $size})">
                    <xsl:apply-templates mode="svg">
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                    </xsl:apply-templates>
                </svg:g>
            </xsl:for-each>
            <xsl:choose>
                <xsl:when test="@use">
                    <svg:use xlink:href="#{@use}" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="grid-warp">
                        <xsl:with-param name="x"><xsl:value-of select="@columns" /></xsl:with-param>
                        <xsl:with-param name="height"><xsl:value-of select="@rows * $size" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="grid-weft">
                        <xsl:with-param name="y"><xsl:value-of select="@rows" /></xsl:with-param>
                        <xsl:with-param name="width"><xsl:value-of select="@columns * $size" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="@right">
                        <svg:rect x="{@columns * $size}" y="{-$border-thickness}"
                                  width="{$border-thickness}" height="{@rows * $size + 2 * $border-thickness}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@right" />
                            </xsl:call-template>
                        </svg:rect>
                        <xsl:if test="not(@right='edge' or @right='none')">
                            <svg:g transform="translate({(@columns + 0.5) * $size}, {@rows * $size div 2})">
                                <xsl:call-template name="svg-player">
                                    <xsl:with-param name="colour" select="@right" />
                                </xsl:call-template>
                            </svg:g>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="@left">
                        <svg:rect x="{-$border-thickness}" y="{-$border-thickness}"
                                  width="{$border-thickness}" height="{@rows * $size + 2 * $border-thickness}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@left" />
                            </xsl:call-template>
                        </svg:rect>
                        <xsl:if test="not(@left='edge' or @left='none')">
                            <svg:g transform="translate({(- 0.5) * $size}, {@rows * $size div 2})">
                                <xsl:call-template name="svg-player">
                                    <xsl:with-param name="colour" select="@left" />
                                </xsl:call-template>
                            </svg:g>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="@bottom">
                        <svg:rect x="{-$border-thickness}" y="{@rows * $size}"
                                  width="{@columns * $size + 2 * $border-thickness}" height="{$border-thickness}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@bottom" />
                            </xsl:call-template>
                        </svg:rect>
                        <xsl:if test="not(@bottom='edge' or @bottom='none')">
                            <svg:g transform="translate({@rows * $size div 2},{(@columns + 0.5) * $size})">
                                <xsl:call-template name="svg-player">
                                    <xsl:with-param name="colour" select="@bottom" />
                                </xsl:call-template>
                            </svg:g>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="@top">
                        <svg:rect x="{-$border-thickness}" y="{-$border-thickness}"
                                  width="{@columns * $size + 2 * $border-thickness}" height="{$border-thickness}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@top" />
                            </xsl:call-template>
                        </svg:rect>
                        <xsl:if test="not(@top='edge' or @top='none')">
                            <svg:g transform="translate({@rows * $size div 2},{(-0.5) * $size})">
                                <xsl:call-template name="svg-player">
                                    <xsl:with-param name="colour" select="@top" />
                                </xsl:call-template>
                            </svg:g>
                        </xsl:if>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </svg:g>
    </xsl:template>

    <xsl:template name="grid-warp">
        <xsl:param name="x"/>
        <xsl:param name="height"/>
        <xsl:param name="size"/>
        <xsl:variable name="protrusion"><xsl:value-of select="$size div $grid-border-fraction * 1.8"/></xsl:variable>
        <xsl:variable name="line-length"><xsl:value-of select="$height + $protrusion"/></xsl:variable>
        <xsl:if test="$x >= 0">
            <svg:path xsl:use-attribute-sets="grid-line">
                <xsl:attribute name="d">
                     M <xsl:value-of select="$x * $size"
                    /><xsl:text> </xsl:text><xsl:value-of select="-($protrusion div 2)"
                    /> l 0 <xsl:value-of select="$height + $protrusion" />
                </xsl:attribute>
            </svg:path>
            <xsl:call-template name="grid-warp">
                <xsl:with-param name="x"><xsl:value-of select="$x - 1" /></xsl:with-param>
                <xsl:with-param name="height"><xsl:value-of select="$height" /></xsl:with-param>
                <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="grid-weft">
        <xsl:param name="y"/>
        <xsl:param name="width"/>
        <xsl:param name="size"/>
        <xsl:variable name="protrusion"><xsl:value-of select="$size div $grid-border-fraction * 1.8"/></xsl:variable>
        <xsl:variable name="line-length"><xsl:value-of select="$width + $protrusion"/></xsl:variable>
        <xsl:if test="$y >= 0">
            <svg:path xsl:use-attribute-sets="grid-line">
                <xsl:attribute name="d">
                    M <xsl:value-of select="-($protrusion div 2)"
                    /><xsl:text> </xsl:text><xsl:value-of select="$y * $size"
                    /> l <xsl:value-of select="$width + $protrusion" /> 0
                </xsl:attribute>
            </svg:path>
            <xsl:call-template name="grid-weft">
                <xsl:with-param name="y"><xsl:value-of select="$y - 1" /></xsl:with-param>
                <xsl:with-param name="width"><xsl:value-of select="$width" /></xsl:with-param>
                <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="highlight" mode="svg" />
    <xsl:template match="highlight" mode="svg-below">
        <xsl:param name="size"/>
        <svg:clipPath id="clip-path-{generate-id(.)}">
            <svg:rect x="{-$size div 2}" y="{-$size div 2}"
                      width="{$size}" height="{$size}" />
        </svg:clipPath>
        <svg:g clip-path="url(#clip-path-{generate-id(.)})">
            <svg:g transform="scale({$size})">
                <svg:use xlink:href="../svg/grid.svg#highlight-{@value}" />
            </svg:g>
        </svg:g>
    </xsl:template>

    <xsl:template match="arrow" mode="svg" />
    <xsl:template match="arrow" mode="svg-below">
        <xsl:param name="size"/>

        <!-- Stroke width here determines arrow size
             so is scaled to square size -->
        <svg:path xsl:use-attribute-sets="arrow"
                  stroke-width="{$size div 20 }">
            <xsl:attribute name="d">M 0 0
                <xsl:if test="@x">l
                    <xsl:value-of select="@x * $size"/>,
                    <xsl:value-of select="@y * $size" />
                </xsl:if>
                <xsl:for-each select="arrow-segment"> l
                    <xsl:value-of select="@x * $size"/>,
                    <xsl:value-of select="@y * $size" />
                </xsl:for-each>
            </xsl:attribute>
        </svg:path>
    </xsl:template>

    <xsl:template match="piece" mode="svg-below" />

    <xsl:template match="callout" mode="svg">
        <xsl:param name="size"/>

        <svg:circle xsl:use-attribute-sets="callout-point"
                    x="0" y="0" r="{$size div 20}" />
        <svg:path xsl:use-attribute-sets="callout"
                  stroke-width="{$size div 40 }">
            <xsl:attribute name="d">M 0 0
                <xsl:if test="@x">l
                    <xsl:value-of select="@x * $size"/>,
                    <xsl:value-of select="@y * $size" />
                </xsl:if>
                <xsl:for-each select="callout-segment"> l
                    <xsl:value-of select="@x * $size"/>,
                    <xsl:value-of select="@y * $size" />
                </xsl:for-each>
            </xsl:attribute>
        </svg:path>
        <xsl:call-template name="callout-text">
            <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="callout-text">
        <xsl:param name="size"/>
        <xsl:variable name="x" select="@x" />
        <xsl:variable name="y" select="@y" />
            <svg:g transform="translate({$x * $size},{$y * $size})">
                <xsl:choose>
                    <xsl:when test="callout-segment">
                        <xsl:for-each select="callout-segment[1]">
                            <xsl:call-template name="callout-text">
                                <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="following-sibling::callout-segment">
                        <xsl:for-each select="following-sibling::callout-segment[1]">
                            <xsl:call-template name="callout-text">
                                <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <svg:g transform="translate(0 {-count(node()) * 3})">
                            <svg:rect x="-8" y="-4" width="16" height="{count(node()) * 6 + 8}"
                                  xsl:use-attribute-sets="callout-box"
                                  stroke-width="{$size div 40 }"/>
                            <xsl:apply-templates mode="svg-callout" />
                        </svg:g>
                    </xsl:otherwise>
                </xsl:choose>
            </svg:g>
    </xsl:template>

    <xsl:template match="text()[not(normalize-space(.)='')]" mode="svg-callout">
        <svg:text text-anchor="middle" y="{position() * 6}">
            <xsl:value-of select="." />
        </svg:text>
    </xsl:template>

    <xsl:template match="p" mode="svg-callout">
        <svg:text text-anchor="middle" y="{position() * 6}">
            <xsl:value-of select="." />
        </svg:text>
    </xsl:template>

    <xsl:template match="player" mode="svg-callout">
        <svg:g transform="translate(0 {position() * 6})">
            <xsl:call-template name="svg-player"/>
        </svg:g>
    </xsl:template>

    <xsl:template match="piece" mode="svg-callout">
        <svg:g transform="translate(0 {position() * 6})">
            <xsl:call-template name="svg-piece"/>
        </svg:g>
    </xsl:template>

</xsl:stylesheet>
