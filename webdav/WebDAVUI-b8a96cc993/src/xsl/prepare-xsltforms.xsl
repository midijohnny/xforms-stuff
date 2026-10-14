<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xsl:stylesheet/@version |
                         xsl:transform/@version"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:attribute name="version">2.0</xsl:attribute>
    </xsl:template>
</xsl:stylesheet>
<!-- 
This xslt is unused in fact: the idea was to get xmlcalabash to run an XSLT Version 1.0 (xsltforms.xsl) as if it was a Version 2.0.
Unfortunately: for this particular instance, that approach doesn't work - it appears that it doesn't like the WebDAV namespace not being a URL (it is a URN)?
-->
