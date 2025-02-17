<xsl:stylesheet
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:ui="urn:app.model.ui">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template name="add_attributes">
		<xsl:for-each select="@*">
			<xsl:attribute name="{name(.)}">
				<xsl:value-of select="."/>
			</xsl:attribute>
		</xsl:for-each>
		<xsl:attribute name="ui:icon"/>
		<xsl:attribute name="ui:expanded"/>
		<xsl:attribute name="ui:class"/>
	</xsl:template>

	<xsl:template match="/">
		<xsl:apply-templates select="tables"/>
	</xsl:template>

	<xsl:template match="tables">
		<tables>
			<xsl:call-template name="add_attributes"/>
			<xsl:apply-templates select="table"/>
		</tables>
	</xsl:template>

	<xsl:template match="table">
		<table>
			<xsl:call-template name="add_attributes"/>
			<xsl:apply-templates select="column"/>
			<xsl:copy-of select="*[name()!='column']"/>
		</table>
	</xsl:template>

	<!-- Column is a leaf node: we only add icon attribute -->
	<!-- In fact: the current bind logic in the 'show_tables.xml' file will fail to work if the 'expanded' attribute is present! -->
	<xsl:template match="column">
		<column>
			<xsl:for-each select="@*">
				<xsl:attribute name="{name(.)}">
					<xsl:value-of select="."/>
				</xsl:attribute>
			</xsl:for-each>
		<xsl:attribute name="ui:icon"/>
		</column>
	</xsl:template>
	
</xsl:stylesheet>
