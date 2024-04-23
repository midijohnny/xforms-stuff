XSLTFORMS=declarative4all/build/xsl/xsltforms.xsl
PAHOJS=js/
mqtt.xml: ${XSLTFORMS} ${PAHOJS}

${XSLTFORMS}:
	git clone https://github.com/AlainCouthures/declarative4all.git

${PAHOJS}:
	mkdir js
	curl https://raw.githubusercontent.com/eclipse/paho.mqtt.javascript/master/src/paho-mqtt.js --output js/paho-mqtt.js --location

