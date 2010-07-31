<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:include href="pieces-svg.xsl" />
    <xsl:include href="elements-svg.xsl" />
    <xsl:include href="grid-svg.xsl" />

   <xsl:output method="xml"/>

<xsl:template match="text()[not(normalize-space(.)='')]">
    <xsl:value-of select="." />
</xsl:template>

<xsl:template match="/">
    <fo:root>
      <!--xsl:call-template name="svg-patterns"/-->
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
                        BOARD:
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
                        SETUP:
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
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-4pt">
            <xsl:call-template name="repeat-arrow" />
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="goToPhase">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-4pt">
            <xsl:call-template name="right-arrow" />
        </fo:instream-foreign-object>
        <xsl:apply-templates />
    </xsl:template>

    
    <xsl:template match="phase/name|goToPhase/name">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-4pt">
            <xsl:call-template name="phase-name">
                <xsl:with-param name="value"><xsl:value-of select="."/></xsl:with-param>
            </xsl:call-template>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="player">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-1.5pt">
            <xsl:call-template name="player">
                <xsl:with-param name="colour"><xsl:value-of select="."/></xsl:with-param>
            </xsl:call-template>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="piece">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-1.5pt">
            <xsl:call-template name="piece">
                <xsl:with-param name="colour"><xsl:value-of select="colour"/></xsl:with-param>
                <xsl:with-param name="shape"><xsl:value-of select="shape"/></xsl:with-param>
            </xsl:call-template>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="stack">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-1.5pt">
            <xsl:call-template name="stack"/>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="legal">
        <fo:block>
            <xsl:for-each select="*">
                <xsl:if test="preceding-sibling::*">
                    <xsl:call-template name="right-arrow" />
                </xsl:if>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </fo:block>
    </xsl:template>

    <xsl:template match="illegal">
        <!--FIXME: crossed right arrow-->
        <fo:block>
            <xsl:for-each select="*">
                <xsl:if test="preceding-sibling::*">
                    <xsl:call-template name="right-arrow" />
                </xsl:if>
                <xsl:apply-templates select="."/>
            </xsl:for-each>
        </fo:block>
    </xsl:template>

    <xsl:template match="grid">
        <fo:instream-foreign-object alignment-baseline="alphabetic" alignment-adjust="-1.5pt">
            <xsl:call-template name="grid" />
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
          <xsl:apply-templates />:
       </fo:block>
    </xsl:template>

    <xsl:template match="dd">
      <fo:block>
          <xsl:apply-templates />
      </fo:block>
    </xsl:template>

</xsl:stylesheet>
