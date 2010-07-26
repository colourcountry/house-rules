<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

   <xsl:output method="xml"/>

<xsl:template match="text()[not(normalize-space(.)='')]">
    <xsl:value-of select="." />
</xsl:template>

<xsl:template match="/">
    <fo:root>
      <fo:layout-master-set>
        <fo:simple-page-master master-name="master">
          <fo:region-body 
           region-name="xsl-region-body" 
           margin="1cm" 
            />
          <fo:region-before 
           region-name="xsl-region-before" 
           extent="1cm" 
            display-align="before" />
          <fo:region-after 
           region-name="xsl-region-after" 
           display-align="after"
           extent="1cm" 
           />
        </fo:simple-page-master>
      </fo:layout-master-set>

      <fo:page-sequence master-reference="master">
        <fo:flow flow-name="xsl-region-body">
            <fo:block xsl:use-attribute-sets="all">
              <xsl:apply-templates />
            </fo:block>
        </fo:flow>
      </fo:page-sequence>

    </fo:root>
</xsl:template>

<xsl:attribute-set name="all">
    <xsl:attribute name="font-family">Helvetica</xsl:attribute>
    <xsl:attribute name="font-size">12pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="top">
    <xsl:attribute name="padding-bottom">12pt</xsl:attribute>
    <xsl:attribute name="border-bottom">6pt solid black</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section">
    <xsl:attribute name="padding-top">6pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">18pt</xsl:attribute>
    <xsl:attribute name="border-bottom">4pt solid black</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="title">
    <xsl:attribute name="font-size">32pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="subtitle">
    <xsl:attribute name="font-size">20pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="dt">
    <xsl:attribute name="text-transform">uppercase</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="phasename">
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="fill">none</xsl:attribute>
    <xsl:attribute name="stroke">black</xsl:attribute>
    <xsl:attribute name="stroke-width">1pt</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="outline">
    <xsl:attribute name="fill">none</xsl:attribute>
    <xsl:attribute name="stroke">black</xsl:attribute>
    <xsl:attribute name="stroke-width">1pt</xsl:attribute>
</xsl:attribute-set>

<xsl:template match="game">
    <fo:block xsl:use-attribute-sets="top">
        <xsl:apply-templates select="name" mode="top" />
        <xsl:apply-templates select="gamebody/about" mode="top" />
    </fo:block>
    <fo:block xsl:use-attribute-sets="section">
        <fo:list-block>
            <xsl:apply-templates select="gamebody/players" mode="top" />
            <xsl:apply-templates select="gamebody/board" mode="top" />
            <xsl:apply-templates select="gamebody/setup" mode="top" />
        </fo:list-block>
    </fo:block>
    <xsl:apply-templates select="gamebody" />
</xsl:template>

    <xsl:template match="name" mode="top">
        <fo:inline xsl:use-attribute-sets="title">
            <xsl:value-of select="." />
        </fo:inline>
    </xsl:template>

    <xsl:template match="about" mode="top">
        <fo:inline xsl:use-attribute-sets="subtitle">
            <xsl:value-of select="." />
        </fo:inline>
    </xsl:template>

    <xsl:template match="players" mode="top">
            <fo:list-item>
                <fo:list-item-label>
                    <fo:block xsl:use-attribute-sets="dt">
                        PLAYER <xsl:apply-templates select="player" />
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="80pt">
                    <fo:block>
                        <xsl:apply-templates select="pieces" />
                    </fo:block>
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="board" mode="top">
            <fo:list-item>
                <fo:list-item-label>
                    <fo:block xsl:use-attribute-sets="dt">
                        BOARD
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="80pt">
                    <fo:block>
                        <xsl:apply-templates />
                    </fo:block>
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="setup" mode="top">
            <fo:list-item>
                <fo:list-item-label>
                    <fo:block xsl:use-attribute-sets="dt">
                        SETUP
                        <xsl:call-template name="phase-name">
                            <!-- Empty phase name to get the right height block -->
                            <xsl:with-param name="value"></xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body start-indent="80pt">
                    <fo:block>
                        <xsl:apply-templates />
                        <xsl:call-template name="right-arrow"/>
                        <xsl:call-template name="phase-name">
                            <xsl:with-param name="value">1</xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="about|players|board|setup" />

    <xsl:template match="section">
        <fo:block xsl:use-attribute-sets="section">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>

    <xsl:template match="phase">
        <fo:block xsl:use-attribute-sets="section">
            <xsl:apply-templates />
        </fo:block>
    </xsl:template>

    <xsl:template match="repeat">
        <xsl:apply-templates />
        <xsl:call-template name="right-arrow" />
        <xsl:call-template name="right-arrow" />
    </xsl:template>

    <xsl:template match="goToPhase">
        <xsl:call-template name="right-arrow" />
        <xsl:apply-templates />
    </xsl:template>

    
    <xsl:template match="phase/name|goToPhase/name">
        <xsl:call-template name="phase-name">
            <xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="phase-name">
        <xsl:param name="value" />
        <xsl:param name="width">14pt</xsl:param>
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-4pt">
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
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template name="right-arrow">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-4pt">
            <svg:svg width="18pt" height="18pt">
                <svg:path d="M 5 5 L 5 13 L 9 13 L 9 17 L 17 9 L 9 1 L 9 5 Z"
                          xsl:use-attribute-sets="phasename" />
            </svg:svg>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="player">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-1.5pt">
            <svg:svg width="12pt" height="12pt">
               <xsl:choose>
                   <xsl:when test="text()='black'">
                       <svg:circle cx="6" cy="6" r="5"
                                   fill="black" />
                    </xsl:when>
                </xsl:choose>
                <svg:circle cx="6" cy="6" r="5"
                            xsl:use-attribute-sets="outline" />
            </svg:svg>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="piece">
        <xsl:variable name="width">
               <xsl:choose>
                   <xsl:when test="size/text()='medium'">20</xsl:when>
                   <xsl:when test="size/text()='large'">30</xsl:when>
                   <xsl:otherwise>10</xsl:otherwise>
                </xsl:choose>
        </xsl:variable>
        <xsl:variable name="width-with-stroke">
               <xsl:choose>
                   <xsl:when test="size/text()='medium'">22</xsl:when>
                   <xsl:when test="size/text()='large'">32</xsl:when>
                   <xsl:otherwise>12</xsl:otherwise>
                </xsl:choose>
        </xsl:variable>
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-1.5pt">
            <svg:svg width="{$width-with-stroke}" height="12pt">
               <xsl:choose>
                   <xsl:when test="colour/text()='black'">
                       <svg:rect x="1" y="1" width="{$width}" height="10"
                                   fill="black" />
                    </xsl:when>
                </xsl:choose>
                <svg:rect x="1" y="1" width="{$width}" height="10"
                          xsl:use-attribute-sets="outline" />
            </svg:svg>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="dl">
        <fo:list-block>
            <xsl:apply-templates />
        </fo:list-block>
    </xsl:template>

    <xsl:template match="dlentry">
            <fo:list-item>
                <fo:list-item-label>
                    <xsl:apply-templates select="dt" />
                </fo:list-item-label>
                <fo:list-item-body start-indent="80pt">
                    <xsl:apply-templates select="dd" />
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="dt">
                    <fo:block xsl:use-attribute-sets="dt">
                        <xsl:apply-templates />
                    </fo:block>
    </xsl:template>

    <xsl:template match="dd">
                    <fo:block>
                        <xsl:apply-templates />
                    </fo:block>
    </xsl:template>

</xsl:stylesheet>
