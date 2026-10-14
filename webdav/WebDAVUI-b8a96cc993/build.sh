#!/bin/bash
# xproc xmllint build
# See note below for why.

INFILE=src/xforms/main.xml
ASSEMBLEDFILE=bld/public/main.xhtml
OUTFILE=bld/public/main.html
XSLFILE=bld/public/xsltforms-1.7/xsltforms.xsl

xmllint --xinclude $INFILE \
     | xmlstarlet fo --nsclean \
	 | xsltproc $XSLFILE -  \
	 > $OUTFILE

xmllint --xinclude $INFILE \
     | xmlstarlet fo --nsclean \
	 > $ASSEMBLEDFILE


exit 0
# XPROC3.0 build:
# We have an issue here: xsltforms.xsl is a version 1.0 stylesheet and XProc can't process that.
# We tried altering the "version='1.0'" => "version='2.0'" on the fly, this kinda works; but the xsltforms.xsl choked on the WebDAV namespace.
# Error: err:XC0095 at build.xpl:18:13 (in bld/public/xsltforms-1.7/xsltforms.xsl): XSLT error: The value of the namespace attribute must be a valid URI
#   cause: The value of the namespace attribute must be a valid URI
#   cause: The value of the namespace attribute must be a valid URI
#  XPath error XTDE0865: The value of the namespace attribute must be a valid URI
#
shopt -s expand_aliases
alias xmlcalabash='~/bin/xmlcalabash-3.0.54/xmlcalabash.sh'

xmlcalabash build.xpl 
