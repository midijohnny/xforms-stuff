<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:media="http://search.yahoo.com/mrss/"
	xmlns:atom="http://www.w3.org/2005/Atom"
	xmlns:ppg="http://bbc.co.uk/2009/01/ppgRss"
	xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
	xmlns:metalink="urn:ietf:params:xml:ns:metalink"
	xmlns:dcterms="http://purl.org/dc/terms/">

<xsl:output indent="yes"/>
<xsl:param name="currentPage">1</xsl:param>
<xsl:param name="pageSize">10</xsl:param>

	<xsl:template match="/rss/channel">
		<metalink:metalink>
			<xsl:for-each select="item
									[
										position() &gt;= (($currentPage - 1) * $pageSize + 1)
                    						and
                    			 		position() &lt;= ($currentPage * $pageSize)
									]">
				<metalink:file name="{translate(guid,':?/+','_')}.mp3"> <!-- note we over-ride this in the xforms-app itself -->
					<metalink:description>
						<xsl:value-of select="description"/>
					</metalink:description>
					<metalink:url>
						<xsl:value-of select="enclosure/@url"/>
					</metalink:url>
					
					<xsl:call-template name="dcterms"/>
				
				</metalink:file>
			</xsl:for-each>
		</metalink:metalink>
	</xsl:template>

	<xsl:template name="dcterms">
		 <dcterms:title>
			<xsl:value-of select="title"/>
		</dcterms:title>
    	<dcterms:isPartOf>
			<xsl:value-of select="../title"/>
		</dcterms:isPartOf>
    	<dcterms:relation>
			<xsl:value-of select="../link"/>
		</dcterms:relation>
    	<dcterms:identifier>
			<xsl:value-of select="guid"/>
		</dcterms:identifier>
	</xsl:template>

</xsl:stylesheet>
