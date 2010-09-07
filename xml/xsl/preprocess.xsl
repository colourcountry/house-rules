<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:svg="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     xmlns:fo="http://www.w3.org/1999/XSL/Format">


    <xsl:output method="xml"/>

    <xsl:template match="*">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="@*" mode="use" />
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{name()}">
            <xsl:value-of select="." />
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@use" mode="use">
        <xsl:choose>
            <xsl:when test="substring-before(.,'#')">
                <xsl:variable name="elem-id" select="substring-after(.,'#')"/>
                <xsl:message>found other-file 'use': <xsl:value-of select="." /></xsl:message>
                <xsl:apply-templates select="document(substring-before(.,'#'),.)//*[@id=$elem-id]" />
            </xsl:when>
            <xsl:when test="contains(.,'#')">
                <xsl:variable name="elem-id" select="substring-after(.,'#')"/>
                <xsl:message>found within-file 'use': <xsl:value-of select="." /></xsl:message>
                <xsl:apply-templates select="//*[@id=$elem-id]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>found old style 'use': <xsl:value-of select="." /></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="grid/@id" priority="3" />

    <xsl:template match="grid/@use" priority="3" />

    <xsl:template match="grid/@use" mode="use" priority="3">
        <xsl:choose>
            <xsl:when test="substring-before(.,'#')">
                <xsl:variable name="elem-id" select="substring-after(.,'#')"/>
                <xsl:message>found other-file 'use': <xsl:value-of select="." /></xsl:message>
                <xsl:variable name="used-grid" select="document(substring-before(.,'#'),.)//grid[@id=$elem-id]" />
                    <xsl:apply-templates select="$used-grid/@*" />
                    <xsl:apply-templates select="$used-grid/*" />
                    <xsl:apply-templates select="../*" />
            </xsl:when>
            <xsl:when test="contains(.,'#')">
                <xsl:variable name="elem-id" select="substring-after(.,'#')"/>
                <xsl:message>found within-file 'use': <xsl:value-of select="." /></xsl:message>
                <xsl:variable name="used-grid" select="//grid[@id=$elem-id]" />
                    <xsl:apply-templates select="$used-grid/@*" />
                    <xsl:apply-templates select="$used-grid/*" />
                    <xsl:apply-templates select="../*" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="elem-id" select="normalize-space(.)"/>
                <xsl:message>found old style 'use': <xsl:value-of select="." /></xsl:message>
                <xsl:variable name="used-grid" select="//grid[@id=$elem-id]" />
                <grid>
                    <xsl:apply-templates select="$used-grid/@*" />
                    <xsl:apply-templates select="$used-grid/*" />
                    <xsl:apply-templates select="../*" />
                </grid>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
