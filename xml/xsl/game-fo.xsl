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
        <xsl:attribute name="font-family">Fontin</xsl:attribute>
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="line-height">14pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="top">
        <xsl:attribute name="padding-bottom">6pt</xsl:attribute>
        <xsl:attribute name="border-bottom">4pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="list-label">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="color"> <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="condition">
        <xsl:attribute name="font-style">italic</xsl:attribute>
        <xsl:attribute name="color"> <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="section">
        <xsl:attribute name="padding-top">4pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">18pt</xsl:attribute>
        <xsl:attribute name="border-top">2pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subsection">
        <xsl:attribute name="padding-bottom">18pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="paragraph">
        <xsl:attribute name="padding-bottom">8pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subsection-body">
        <xsl:attribute name="padding-top">6pt</xsl:attribute>
        <xsl:attribute name="border-top">2pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="example">
        <xsl:attribute name="border-top">1pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
        <xsl:attribute name="border-left">1pt solid <xsl:value-of select="$rule-colour" /></xsl:attribute>
        <xsl:attribute name="padding">6pt</xsl:attribute>
        <xsl:attribute name="margin-top">12pt</xsl:attribute>
        <xsl:attribute name="margin-right">40pt</xsl:attribute>
        <xsl:attribute name="margin-left">2pt</xsl:attribute>
        <!-- Doesn't work -->
        <xsl:attribute name="keep-together.within-line">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="legal-or-illegal">
        <!-- Doesn't work -->
        <xsl:attribute name="margin-right">30pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="title">
        <xsl:attribute name="font-size">24pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="subtitle">
        <xsl:attribute name="font-size">14pt</xsl:attribute>
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

    <xsl:attribute-set name="align-bullets">
        <xsl:attribute name="alignment-baseline">alphabetic</xsl:attribute>
        <xsl:attribute name="alignment-adjust">-6pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="phase-name">
        <xsl:attribute name="alignment-baseline">alphabetic</xsl:attribute>
        <xsl:attribute name="alignment-adjust">-1pt</xsl:attribute>
        <xsl:attribute name="font-size">18pt</xsl:attribute>
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
        <xsl:if test="gamebody/players">
            <fo:block xsl:use-attribute-sets="subsection">
                <fo:table>
                    <fo:table-column column-width="80pt" />
                    <fo:table-column />
                    <fo:table-body>
                        <xsl:apply-templates select="gamebody/players" mode="fo-top" />
                        <xsl:apply-templates select="gamebody/pieces" mode="fo-top" />
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </xsl:if>
        <xsl:apply-templates select="gamebody" mode="fo" />
    </xsl:template>

    <xsl:template match="name" mode="fo-top">
        <fo:inline xsl:use-attribute-sets="title">
            <xsl:value-of select="." />
        </fo:inline>
    </xsl:template>

    <xsl:template match="about" mode="fo-top">
        <fo:inline xsl:use-attribute-sets="subtitle">
            <fo:leader leader-length="5px" />
            <xsl:value-of select="author" />
            <fo:leader leader-length="5px" />
            <xsl:value-of select="date" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="players[pieces]" mode="fo-top" priority="2">
            <fo:table-row>
                <fo:table-cell>
                    <fo:block>
                      <fo:inline xsl:use-attribute-sets="keyword">
                        PLAYER
                      </fo:inline>
                      <xsl:apply-templates select="player" mode="fo" />:
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block>
                        <xsl:apply-templates select="pieces/node()" mode="fo" />
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
    </xsl:template>

    <xsl:template match="players" mode="fo-top">
            <fo:table-row>
                <fo:table-cell>
                    <fo:block>
                      <fo:inline xsl:use-attribute-sets="keyword">
                        PLAYERS:
                      </fo:inline>
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block>
                        <xsl:apply-templates mode="fo" />
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
    </xsl:template>

    <xsl:template match="pieces" mode="fo-top">
            <fo:table-row>
                <fo:table-cell>
                    <fo:block>
                      <fo:inline xsl:use-attribute-sets="keyword">
                        PIECES:
                      </fo:inline>
                    </fo:block>
                </fo:table-cell>
                <fo:table-cell>
                    <fo:block>
                        <xsl:apply-templates mode="fo" />
                    </fo:block>
                </fo:table-cell>
            </fo:table-row>
    </xsl:template>

    <xsl:template match="about|players|pieces" mode="fo" />

    <xsl:template match="section" mode="fo">
        <fo:block xsl:use-attribute-sets="section">
            <xsl:apply-templates mode="fo" />
        </fo:block>
    </xsl:template>

    <xsl:template match="phase" mode="fo">
        <fo:block xsl:use-attribute-sets="section">
            <fo:table>
            <fo:table-column column-width="80pt" />
            <fo:table-column />
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell>
                        <fo:block>
                            <xsl:apply-templates select="phaseName" mode="fo-label" />
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block>
                            <xsl:apply-templates mode="fo" />
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template match="subphase" mode="fo">
        <fo:block xsl:use-attribute-sets="subsection">
            <fo:table>
            <fo:table-column column-width="80pt" />
            <fo:table-column />
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell>
                        <fo:block>
                            <xsl:apply-templates select="phaseName" mode="fo-label" />
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="subsection-body">
                            <xsl:apply-templates mode="fo" />
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
            </fo:table>
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

    <xsl:template match="hide" mode="fo" />

    <xsl:template match="grid" mode="fo">
        <xsl:variable name="height"><xsl:call-template name="get-grid-height"/></xsl:variable>
        <xsl:variable name="scale">
            <xsl:choose>
                <xsl:when test="@scale"><xsl:value-of select="@scale" /></xsl:when>
                <xsl:otherwise>0.7</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="preceding-sibling::*[1]/name()='grid'">
            <fo:leader leader-length="40px" />
        </xsl:if>
        <fo:instream-foreign-object alignment-baseline="alphabetic"
                                    alignment-adjust="{-$height div 2 * $scale + 5}px">
            <xsl:call-template name="svg-with-grid">
                <xsl:with-param name="scale" select="$scale" />
            </xsl:call-template>
        </fo:instream-foreign-object>
    </xsl:template>

    <xsl:template match="dl" mode="fo">
        <fo:block xsl:use-attribute-sets="section">
            <fo:table>
            <fo:table-column column-width="80pt" />
            <fo:table-column />
            <fo:table-body>
                <xsl:apply-templates mode="fo" />
            </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template match="keyword" mode="fo">
        <fo:inline xsl:use-attribute-sets="keyword">
            <xsl:apply-templates mode="fo" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="dlentry" mode="fo">
            <fo:table-row>
                <fo:table-cell>
                    <xsl:apply-templates select="dt" mode="fo" />
                </fo:table-cell>
                <fo:table-cell>
                    <xsl:choose>
                        <xsl:when test="preceding-sibling::dlentry">
                            <fo:block xsl:use-attribute-sets="subsection-body">
                                <xsl:apply-templates select="dd" mode="fo" />
                            </fo:block>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block>
                                <xsl:apply-templates select="dd" mode="fo" />
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:table-cell>
            </fo:table-row>
    </xsl:template>

    <xsl:template match="dt" mode="fo">
      <fo:block>
          <xsl:apply-templates mode="fo" />:
       </fo:block>
    </xsl:template>

    <xsl:template match="p" mode="fo">
      <fo:block xsl:use-attribute-sets="paragraph">
          <xsl:apply-templates mode="fo" />
       </fo:block>
    </xsl:template>

    <xsl:template match="ul" mode="fo">
      <fo:block xsl:use-attribute-sets="paragraph">
          <fo:list-block>
              <xsl:apply-templates mode="fo" />
          </fo:list-block>
       </fo:block>
    </xsl:template>

    <xsl:template match="ol/li" mode="fo">
        <fo:list-item>
            <fo:list-item-label>
                <fo:block xsl:use-attribute-sets="list-label">
                    <xsl:value-of select="count(preceding-sibling::li) + 1" />
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body margin-left="10pt">
                <fo:block>
                  <xsl:apply-templates mode="fo" />
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

    <xsl:template match="ul/li" mode="fo">
        <fo:list-item>
            <fo:list-item-label>
                <fo:block xsl:use-attribute-sets="list-label">
                    <fo:instream-foreign-object xsl:use-attribute-sets="align-bullets">
                        <xsl:call-template name="svg-with-bullet" />
                    </fo:instream-foreign-object>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body margin-left="10pt">
                <fo:block>
                  <xsl:apply-templates mode="fo" />
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

    <xsl:template match="ol" mode="fo">
      <fo:block xsl:use-attribute-sets="paragraph">
          <fo:list-block>
              <xsl:apply-templates mode="fo" />
          </fo:list-block>
       </fo:block>
    </xsl:template>

    <xsl:template match="dd" mode="fo">
      <fo:block xsl:use-attribute-sets="paragraph">
          <xsl:apply-templates mode="fo" />
      </fo:block>
    </xsl:template>

    <xsl:template match="condition" mode="fo">
        <fo:inline xsl:use-attribute-sets="condition">
            <xsl:value-of select="@value" />
        </fo:inline>
    </xsl:template>

    <xsl:template match="step" mode="fo">
        <fo:inline xsl:use-attribute-sets="list-label">
           <xsl:value-of select="@value" />
        </fo:inline>
    </xsl:template>

</xsl:stylesheet>
