<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
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

    <xsl:attribute-set name="black-line">
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">black</xsl:attribute>
        <xsl:attribute name="stroke-width">0.8pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="white-line">
        <xsl:attribute name="fill">none</xsl:attribute>
        <xsl:attribute name="stroke">white</xsl:attribute>
        <xsl:attribute name="stroke-width">0.8pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:template name="svg-patterns">
        <svg:pattern id="test" x="10" y="10" width="20" height="20">
            <svg:rect x="5" y="5" width="10" height="10"/>
        </svg:pattern>
    </xsl:template>

    <xsl:template name="player">
        <xsl:param name="colour"/>
        <svg:svg width="12pt" height="12pt">
           <xsl:choose>
               <xsl:when test="$colour='black'">
                   <svg:circle cx="6" cy="6" r="5"
                               fill="black" />
               </xsl:when>
           </xsl:choose>
           <svg:circle cx="6" cy="6" r="5"
                        xsl:use-attribute-sets="outline" />
           </svg:svg>
    </xsl:template>

    <xsl:template name="piece">
        <xsl:param name="colour"/>
        <xsl:param name="size"/>
        <xsl:variable name="width">
               <xsl:choose>
                   <xsl:when test="$size='small'">10</xsl:when>
                   <xsl:when test="$size='medium'">20</xsl:when>
                   <xsl:when test="$size='large'">30</xsl:when>
                   <xsl:otherwise><xsl:value-of select="$size"/></xsl:otherwise>
                </xsl:choose>
        </xsl:variable>
        <svg:svg width="{$width+2}" height="12pt">
            <xsl:call-template name="piece-impl">
                <xsl:with-param name="colour"><xsl:value-of select="$colour" /></xsl:with-param>
                <xsl:with-param name="width"><xsl:value-of select="$width" /></xsl:with-param>
                <xsl:with-param name="y">1</xsl:with-param>
                <xsl:with-param name="x">1</xsl:with-param>
            </xsl:call-template>
        </svg:svg>
    </xsl:template>

    <xsl:template name="stack">
        <xsl:param name="height"><xsl:value-of select="count(piece)*8 + 2"/></xsl:param>
        <svg:svg width="40" height="{$height}">
            <xsl:for-each select="piece">
                <xsl:call-template name="piece-impl">
                    <xsl:with-param name="colour"><xsl:value-of select="colour" /></xsl:with-param>
                    <xsl:with-param name="width">
                        <xsl:choose>
                            <xsl:when test="size='small'">10</xsl:when>
                            <xsl:when test="size='medium'">20</xsl:when>
                            <xsl:when test="size='large'">30</xsl:when>
                            <xsl:otherwise><xsl:value-of select="size"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="cy"><xsl:value-of select="3 + $height - position()*8"/></xsl:with-param>
                    <xsl:with-param name="cx">20</xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </svg:svg>
    </xsl:template>

    <xsl:template name="piece-impl">
        <xsl:param name="cy">0</xsl:param>
        <xsl:param name="cx">0</xsl:param>
        <xsl:param name="colour"/>
        <xsl:param name="width"/>
        <xsl:param name="y"><xsl:value-of select="$cy - 5" /></xsl:param>
        <xsl:param name="x"><xsl:value-of select="$cx - ($width div 2)" /></xsl:param>
        <xsl:choose>
          <xsl:when test="contains('purple orange blue red black', $colour)">
            <svg:rect x="{$x + 1}" y="{$y + 1}" width="{$width - 2}" height="8"
                      xsl:use-attribute-sets="fill" />
          </xsl:when>
          <xsl:otherwise>
            <svg:rect x="{$x + 1}" y="{$y + 1}" width="{$width - 2}" height="8"
                     xsl:use-attribute-sets="outline" />
          </xsl:otherwise>
        </xsl:choose>
        <svg:clipPath id="{generate-id(.)}">
            <svg:rect x="{$x + 1.5}" y="{$y + 1.5}" width="{$width - 3}" height="7"/>
        </svg:clipPath>
        <xsl:choose>
            <xsl:when test="$colour='purple'">
                <svg:path d="M {$x}  {$y} l 10 10 l 10 -10 l 10 10 l 10 -10"
                            xsl:use-attribute-sets="white-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
            <xsl:when test="$colour='yellow'">
                <svg:path d="M {$x}  {$y} l 10 10 l 10 -10 l 10 10 l 10 -10"
                            xsl:use-attribute-sets="black-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
            <xsl:when test="$colour='orange'">
                <svg:path d="M {$x}  {$y} l 10 10 l 10 -10 l 10 10 l 10 -10 m 0 10 l -10 -10 l -10 10 l -10 -10 l -10 10"
                            xsl:use-attribute-sets="white-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
            <xsl:when test="$colour='green'">
                <svg:path d="M {$x}  {$y} l 10 10 l 10 -10 l 10 10 l 10 -10 m 0 10 l -10 -10 l -10 10 l -10 -10 l -10 10"
                            xsl:use-attribute-sets="black-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
            <xsl:when test="$colour='blue'">
                <svg:path d="M {$x + 4}  {$y} l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 "
                            xsl:use-attribute-sets="white-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
            <xsl:when test="$colour='clear'">
                <svg:path d="M {$x + 4}  {$y} l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 "
                            xsl:use-attribute-sets="black-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
            <xsl:when test="$colour='red'">
                <svg:path d="M {$x + 4}  {$y} l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 M {$x} {$y + 4} l 40 0 m 0 2 l -40 0"
                            xsl:use-attribute-sets="white-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
            <xsl:when test="$colour='teal'">
                <svg:path d="M {$x + 4}  {$y} l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 l 0 10 m 2 0 l 0 -10 m 8 0 M {$x} {$y + 4} l 40 0 m 0 2 l -40 0"
                            xsl:use-attribute-sets="black-line" clip-path="url(#{generate-id(.)})" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
