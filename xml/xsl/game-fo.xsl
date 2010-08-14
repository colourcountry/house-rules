<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:param name="rule-colour">#ff8800</xsl:param>

    <xsl:template match="text()[not(normalize-space(.)='')]" mode="fo">
        <xsl:value-of select="." />
    </xsl:template>

    <xsl:template match="/" mode="fo">
        <fo:root>
          <fo:layout-master-set>
            <fo:simple-page-master master-name="A4"
                                   page-width="210mm"
                                   page-height="297mm">
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
            <fo:simple-page-master master-name="A5"
                                   page-width="148.5mm"
                                   page-height="210mm">
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

          <fo:page-sequence master-reference="A5">
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="all">
                  <xsl:apply-templates mode="fo"/>
                </fo:block>
            </fo:flow>
          </fo:page-sequence>

        </fo:root>
    </xsl:template>

    <xsl:attribute-set name="all">
        <xsl:attribute name="font-family">Helvetica</xsl:attribute>
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="line-height">18pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="top">
        <xsl:attribute name="padding-bottom">12pt</xsl:attribute>
        <xsl:attribute name="border-bottom">6pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section">
        <xsl:attribute name="padding-top">6pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">18pt</xsl:attribute>
        <xsl:attribute name="border-top">2pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subsection">
        <xsl:attribute name="padding-bottom">18pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subsection-body">
        <xsl:attribute name="padding-top">6pt</xsl:attribute>
        <xsl:attribute name="border-top">2pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="example">
        <xsl:attribute name="border-top">1pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
        <xsl:attribute name="padding">6pt</xsl:attribute>
        <xsl:attribute name="margin-top">12pt</xsl:attribute>
        <xsl:attribute name="margin-right">40pt</xsl:attribute>
        <!-- Doesn't work -->
        <xsl:attribute name="keep-together.within-line">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="legal-or-illegal">
        <!-- Doesn't work -->
        <xsl:attribute name="margin-right">30pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="title">
        <xsl:attribute name="font-size">32pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subtitle">
        <xsl:attribute name="font-size">20pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="keyword">
        <xsl:attribute name="text-transform">uppercase</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="align-arrows">
        <xsl:attribute name="alignment-baseline">alphabetic</xsl:attribute>
        <xsl:attribute name="alignment-adjust">-4pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="phase-name">
        <xsl:attribute name="alignment-baseline">alphabetic</xsl:attribute>
        <xsl:attribute name="alignment-adjust">-4pt</xsl:attribute>
        <xsl:attribute name="font-size">24pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="color"><xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>


    <xsl:attribute-set name="align-pieces">
        <xsl:attribute name="alignment-baseline">alphabetic</xsl:attribute>
        <xsl:attribute name="alignment-adjust">-1.5pt</xsl:attribute>
    </xsl:attribute-set>


    <xsl:template match="game" mode="fo">
        <fo:block xsl:use-attribute-sets="top">
            <xsl:apply-templates select="name" mode="fo-top" />
            <xsl:apply-templates select="gamebody/about" mode="fo-top" />
        </fo:block>
        <fo:block xsl:use-attribute-sets="subsection">
            <fo:list-block>
                <xsl:apply-templates select="gamebody/players" mode="fo-top" />
                <xsl:apply-templates select="gamebody/board" mode="fo-top" />
                <xsl:apply-templates select="gamebody/setup" mode="fo-top" />
            </fo:list-block>
        </fo:block>
        <xsl:apply-templates select="gamebody" mode="fo" />
    </xsl:template>

    <xsl:template match="name" mode="fo-top">
        <fo:inline xsl:use-attribute-sets="title">
            <xsl:value-of select="." />
        </fo:inline>
    </xsl:template>

    <xsl:template match="about" mode="fo-top">
        <fo:inline xsl:use-attribute-sets="subtitle">
            <xsl:value-of select="." />
        </fo:inline>
    </xsl:template>

    <xsl:template match="players" mode="fo-top">
            <fo:list-item>
                <fo:list-item-label>
                    <fo:block>
                      <fo:inline xsl:use-attribute-sets="keyword">
                        PLAYER
                      </fo:inline>
                      <xsl:apply-templates select="player" mode="fo" />
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body margin-left="80pt">
                    <fo:block>
                        <xsl:apply-templates select="pieces" mode="fo" />
                    </fo:block>
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="board" mode="fo-top">
            <fo:list-item>
                <fo:list-item-label>
                    <fo:block>
                      <fo:inline xsl:use-attribute-sets="keyword">
                        BOARD
                      </fo:inline>:
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body margin-left="80pt">
                    <fo:block>
                        <xsl:apply-templates mode="fo" />
                    </fo:block>
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="setup" mode="fo-top">
            <fo:list-item>
                <fo:list-item-label>
                    <fo:block>
                        <fo:inline xsl:use-attribute-sets="keyword">
                            SETUP
                        </fo:inline>:
                        <xsl:call-template name="phase-name">
                            <!-- Empty phase name to get the right height block -->
                            <xsl:with-param name="value"></xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body margin-left="80pt">
                    <fo:block>
                        <xsl:apply-templates mode="fo" />
                        <fo:instream-foreign-object xsl:use-attribute-sets="align-arrows">
                            <xsl:call-template name="svg-with-right-arrow" />
                        </fo:instream-foreign-object>
                        <xsl:call-template name="phase-name">
                            <xsl:with-param name="value">1</xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="about|players|board|setup" mode="fo" />

    <xsl:template match="section" mode="fo">
        <fo:block xsl:use-attribute-sets="section">
            <xsl:apply-templates mode="fo" />
        </fo:block>
    </xsl:template>

    <xsl:template match="phase" mode="fo">
        <fo:block xsl:use-attribute-sets="section">
            <fo:list-block>
                <fo:list-item>
                    <fo:list-item-label>
                        <fo:block>
                            <xsl:apply-templates select="phaseName" mode="fo-label" />
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body margin-left="80pt">
                        <fo:block>
                            <xsl:apply-templates mode="fo" />
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </fo:list-block>
        </fo:block>
    </xsl:template>

    <xsl:template match="subphase" mode="fo">
        <fo:block xsl:use-attribute-sets="subsection">
            <fo:list-block>
                <fo:list-item>
                    <fo:list-item-label>
                        <fo:block>
                            <xsl:apply-templates select="phaseName" mode="fo-label" />
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body margin-left="80pt">
                        <fo:block xsl:use-attribute-sets="subsection-body">
                            <xsl:apply-templates mode="fo" />
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </fo:list-block>
        </fo:block>
    </xsl:template>

    <xsl:template match="phaseName" mode="fo-label">
        <xsl:apply-templates mode="fo" />
    </xsl:template>

    <xsl:template name="phase-name">
        <xsl:param name="value" />
        <fo:inline xsl:use-attribute-sets="phase-name">
            <xsl:value-of select="$value" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="phaseName" mode="fo" />

    <xsl:template match="repeat" mode="fo">
        <xsl:apply-templates mode="fo" />
        <fo:instream-foreign-object xsl:use-attribute-sets="align-arrows">
            <xsl:call-template name="svg-with-repeat-arrow" />
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="goToPhase" mode="fo">
        <fo:inline keep-together.within-line="always">
            <fo:instream-foreign-object xsl:use-attribute-sets="align-arrows">
                <xsl:call-template name="svg-with-right-arrow" />
            </fo:instream-foreign-object>
            <xsl:apply-templates mode="fo" />
        </fo:inline>
    </xsl:template>

    
    <xsl:template match="phaseNumber" mode="fo">
        <xsl:call-template name="phase-name">
            <xsl:with-param name="value"><xsl:value-of select="@value"/></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="player" mode="fo">
        <fo:instream-foreign-object xsl:use-attribute-sets="align-pieces">
            <xsl:call-template name="svg-with-player"/>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="piece" mode="fo">
        <fo:instream-foreign-object xsl:use-attribute-sets="align-pieces">
            <xsl:call-template name="svg-with-piece"/>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="stack" mode="fo">
        <fo:instream-foreign-object xsl:use-attribute-sets="align-pieces">
            <xsl:call-template name="svg-with-stack"/>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="example" mode="fo">
        <fo:block xsl:use-attribute-sets="example">
            <xsl:apply-templates mode="fo" />
        </fo:block>
    </xsl:template>

    <xsl:template match="legal" mode="fo">
        <fo:inline xsl:use-attribute-sets="legal-or-illegal">
                <xsl:for-each select="*">
                    <fo:instream-foreign-object xsl:use-attribute-sets="align-arrows">
                        <xsl:call-template name="svg-with-right-arrow" />
                    </fo:instream-foreign-object>
                    <xsl:apply-templates select="." mode="fo" />
                </xsl:for-each>
                <fo:leader leader-length="40px" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="forced" mode="fo">
        <fo:inline xsl:use-attribute-sets="legal-or-illegal">
                <xsl:for-each select="*">
                    <fo:instream-foreign-object xsl:use-attribute-sets="align-arrows">
                        <xsl:call-template name="svg-with-forced-right-arrow" />
                    </fo:instream-foreign-object>
                    <xsl:apply-templates select="." mode="fo" />
                </xsl:for-each>
                <fo:leader leader-length="40px" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="illegal" mode="fo">
        <fo:inline xsl:use-attribute-sets="legal-or-illegal">
                <xsl:for-each select="*">
                    <fo:instream-foreign-object xsl:use-attribute-sets="align-arrows">
                        <xsl:call-template name="svg-with-crossed-right-arrow" />
                    </fo:instream-foreign-object>
                    <xsl:apply-templates select="." mode="fo" />
                </xsl:for-each>
        </fo:inline>
    </xsl:template>

    <xsl:template match="grid" mode="fo">
        <xsl:variable name="height"><xsl:call-template name="get-grid-height"/></xsl:variable>
        <xsl:variable name="scale">
            <xsl:choose>
                <xsl:when test="@scale"><xsl:value-of select="@scale" /></xsl:when>
                <xsl:otherwise>0.7</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fo:instream-foreign-object alignment-baseline="alphabetic"
                                    alignment-adjust="{-$height div 2 * $scale + 5}px">
            <xsl:call-template name="svg-with-grid">
                <xsl:with-param name="scale" select="$scale" />
            </xsl:call-template>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="dl" mode="fo">
        <fo:block xsl:use-attribute-sets="section">
            <fo:list-block>
                <xsl:apply-templates mode="fo" />
            </fo:list-block>
        </fo:block>
    </xsl:template>

    <xsl:template match="keyword" mode="fo">
        <fo:inline xsl:use-attribute-sets="keyword">
            <xsl:apply-templates mode="fo" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="dlentry" mode="fo">
            <fo:list-item>
                <fo:list-item-label>
                    <xsl:apply-templates select="dt" mode="fo" />
                </fo:list-item-label>
                <fo:list-item-body margin-left="80pt">
                    <xsl:apply-templates select="dd" mode="fo" />
                </fo:list-item-body>
            </fo:list-item>
    </xsl:template>

    <xsl:template match="dt" mode="fo">
      <fo:block>
          <xsl:apply-templates mode="fo" />:
       </fo:block>
    </xsl:template>

    <xsl:template match="line" mode="fo">
      <fo:block>
          <xsl:apply-templates mode="fo" />
       </fo:block>
    </xsl:template>

    <xsl:template match="dd" mode="fo">
      <fo:block>
          <xsl:apply-templates mode="fo" />
      </fo:block>
    </xsl:template>

</xsl:stylesheet>