<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:template name="get-octa-grid-height">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-octa-grid-height" />
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
                <xsl:value-of select="(@rows) * 36 * $size" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-octa-grid-width">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-octa-grid-width" />
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
                <xsl:value-of select="(@columns) * 36 * $size" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-octa-grid-size">
        <xsl:choose>
            <xsl:when test="@use">
                <xsl:variable name="use" select="@use" />
                <xsl:for-each select="//*[@id=$use]">
                    <xsl:call-template name="get-octa-grid-size" />
                </xsl:for-each>                
            </xsl:when>
            <xsl:when test="@size='small'">18</xsl:when>
            <xsl:when test="@size='medium'">24</xsl:when>
            <xsl:when test="@size"><xsl:value-of select="36 * @size"/></xsl:when>
            <xsl:otherwise>36</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="svg-with-octa-grid">
        <xsl:param name="scale">0.7</xsl:param>
        <xsl:variable name="height"><xsl:call-template name="get-octa-grid-height"/></xsl:variable>
        <xsl:variable name="width"><xsl:call-template name="get-octa-grid-width"/></xsl:variable>
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

    <xsl:template name="svg-octa-grid">
        <xsl:variable name="height"><xsl:call-template name="get-octa-grid-height"/></xsl:variable>
        <xsl:variable name="width"><xsl:call-template name="get-octa-grid-width"/></xsl:variable>
        <xsl:variable name="size"><xsl:call-template name="get-octa-grid-size"/></xsl:variable>
        <xsl:variable name="border-thickness"><xsl:value-of select="$size div 8"/></xsl:variable>
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@id"><xsl:value-of select="@id" /></xsl:when>
                <xsl:otherwise>--<xsl:value-of select="generate-id(.)" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message>Drawing octa grid <xsl:value-of select="$id" /></xsl:message>
        <svg:rect x="0" y="0" width="{$width}" height="{$height}"
                         xsl:use-attribute-sets="grid-background" />
        <svg:g id="{$id}">
            <xsl:for-each select="square">
                <svg:g transform="translate({(@x + 0.5) * $size },{(@y + 0.5) * $size })">
                    <xsl:apply-templates mode="svg-below">
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                    </xsl:apply-templates>
                </svg:g>
            </xsl:for-each>
            <xsl:for-each select="square">
                <svg:g transform="translate({(@x + 0.5) * $size },{(@y + 0.5) * $size })">
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
                    <xsl:call-template name="octa-grid-warp">
                        <xsl:with-param name="x"><xsl:value-of select="@columns" /></xsl:with-param>
                        <xsl:with-param name="height"><xsl:value-of select="@rows" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                        <xsl:with-param name="border-thickness"><xsl:value-of select="$border-thickness" /></xsl:with-param>
                    </xsl:call-template>
                    <xsl:call-template name="octa-grid-weft">
                        <xsl:with-param name="y"><xsl:value-of select="@rows" /></xsl:with-param>
                        <xsl:with-param name="width"><xsl:value-of select="@columns" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                        <xsl:with-param name="border-thickness"><xsl:value-of select="$border-thickness" /></xsl:with-param>
                    </xsl:call-template>
                    <xsl:if test="@right">
                        <svg:rect x="{$width - $border-thickness + 0.4}" y="0"
                                  width="{$border-thickness - 0.4}" height="{$height}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@right" />
                            </xsl:call-template>
                        </svg:rect>
                    </xsl:if>
                    <xsl:if test="@left">
                        <svg:rect x="0" y="0"
                                  width="{$border-thickness - 0.4}" height="{$height}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@left" />
                            </xsl:call-template>
                        </svg:rect>
                    </xsl:if>
                    <xsl:if test="@bottom">
                        <svg:rect x="0" y="{$height - $border-thickness + 0.4}"
                                  width="{$width}" height="{$border-thickness - 0.4}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@bottom" />
                            </xsl:call-template>
                        </svg:rect>
                    </xsl:if>
                    <xsl:if test="@top">
                        <svg:rect x="0" y="0"
                                  width="{$width}" height="{$border-thickness - 0.4}">
                            <xsl:call-template name="grid-attributes">
                                <xsl:with-param name="name" select="@top" />
                            </xsl:call-template>
                        </svg:rect>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </svg:g>
    </xsl:template>

    <xsl:template name="octa-grid-warp-wiggle">
        <xsl:param name="y"/>
        <xsl:param name="x"/>
        <xsl:param name="size"
        /> l <xsl:choose>
            <xsl:when test="(($x+$y) mod 2)=0"><xsl:value-of select="$size * 0.15" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="-$size * 0.15" /></xsl:otherwise>
        </xsl:choose><xsl:text> </xsl:text>
        <xsl:value-of select="$size * 0.15" /> l 0
        <xsl:value-of select="$size * 0.70"
        /> l <xsl:choose>
            <xsl:when test="(($x+$y) mod 2)=0"><xsl:value-of select="-$size * 0.15" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$size * 0.15" /></xsl:otherwise>
        </xsl:choose><xsl:text> </xsl:text>
        <xsl:value-of select="$size * 0.15" />
        <xsl:if test="$y &gt; 0">
                     <xsl:call-template name="octa-grid-warp-wiggle">
                        <xsl:with-param name="y"><xsl:value-of select="$y - 1" /></xsl:with-param>
                        <xsl:with-param name="x"><xsl:value-of select="$x" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                     </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="octa-grid-warp">
        <xsl:param name="x"/>
        <xsl:param name="height"/>
        <xsl:param name="size"/>
        <xsl:param name="border-thickness"/>
        <xsl:if test="$x &gt;= 0">
            <svg:path xsl:use-attribute-sets="grid-line">
                <xsl:attribute name="d"
                     >M <xsl:value-of select="($x) * $size"
                     /> 0 <xsl:call-template name="octa-grid-warp-wiggle">
                        <xsl:with-param name="y"><xsl:value-of select="$height" /></xsl:with-param>
                        <xsl:with-param name="x"><xsl:value-of select="$x" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                     </xsl:call-template>
                </xsl:attribute>
            </svg:path>
            <xsl:call-template name="octa-grid-warp">
                <xsl:with-param name="x"><xsl:value-of select="$x - 1" /></xsl:with-param>
                <xsl:with-param name="height"><xsl:value-of select="$height" /></xsl:with-param>
                <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                <xsl:with-param name="border-thickness"><xsl:value-of select="$border-thickness" /></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="octa-grid-weft-wiggle">
        <xsl:param name="x"/>
        <xsl:param name="y"/>
        <xsl:param name="size"
        /> l <xsl:value-of select="$size * 0.15" />
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="(($x+$y) mod 2)=0"><xsl:value-of select="$size * 0.15" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="-$size * 0.15" /></xsl:otherwise>
        </xsl:choose> l <xsl:value-of select="$size * 0.70"
        /> 0 l <xsl:value-of select="$size * 0.15" />
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="(($x+$y) mod 2)=0"><xsl:value-of select="-$size * 0.15" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="$size * 0.15" /></xsl:otherwise>
        </xsl:choose> 
        <xsl:if test="$x &gt; 0">
                     <xsl:call-template name="octa-grid-weft-wiggle">
                        <xsl:with-param name="x"><xsl:value-of select="$x - 1" /></xsl:with-param>
                        <xsl:with-param name="y"><xsl:value-of select="$y" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                     </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="octa-grid-weft">
        <xsl:param name="y"/>
        <xsl:param name="width"/>
        <xsl:param name="size"/>
        <xsl:param name="border-thickness"/>
        <xsl:if test="$y >= 0">
            <svg:path xsl:use-attribute-sets="grid-line">
                <xsl:attribute name="d"
                     >M 0 <xsl:value-of select="($y) * $size"
                     /><xsl:call-template name="octa-grid-weft-wiggle">
                        <xsl:with-param name="x"><xsl:value-of select="$width" /></xsl:with-param>
                        <xsl:with-param name="y"><xsl:value-of select="$y" /></xsl:with-param>
                        <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                     </xsl:call-template>
                </xsl:attribute>
            </svg:path>
            <xsl:call-template name="octa-grid-weft">
                <xsl:with-param name="y"><xsl:value-of select="$y - 1" /></xsl:with-param>
                <xsl:with-param name="width"><xsl:value-of select="$width" /></xsl:with-param>
                <xsl:with-param name="size"><xsl:value-of select="$size" /></xsl:with-param>
                <xsl:with-param name="border-thickness"><xsl:value-of select="$border-thickness" /></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
