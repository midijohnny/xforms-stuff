<p:declare-step
    xmlns:p="http://www.w3.org/ns/xproc"
    version="3.0">

    <p:input port="source" href="src/xforms/main.xml"/>

    <p:xinclude name="included"/>

    <!-- Prepare the XSLTForms stylesheet -->
    <p:xslt name="prepare">
        <p:with-input port="source"
                      href="bld/public/xsltforms-1.7/xsltforms.xsl"/>
        <p:with-input port="stylesheet"
                      href="src/xsl/prepare-xsltforms.xsl"/>
    </p:xslt>

    <!-- Apply the prepared stylesheet to the XInclude result -->
    <p:xslt>
        <p:with-input port="source" pipe="result@included"/>
        <p:with-input port="stylesheet" pipe="result@prepare"/>
    </p:xslt>

    <p:store
        href="bld/public/main.html"
        serialization="map{'method':'html', 'indent':true()}"/>

</p:declare-step>
