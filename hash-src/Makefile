SRC_DIR := src
SRC_MAIN := $(SRC_DIR)/hash.xml
BUILD_DIR := bld
OUT := $(BUILD_DIR)/hash.xml

XML_DEPS := $(shell find $(SRC_DIR) -type f -name '*.xml')

$(OUT): $(XML_DEPS)
	mkdir -p $(BUILD_DIR)
	xmllint --xinclude $(SRC_MAIN) \
	| xmlstarlet fo --nsclean \
	| xmlstarlet ed -d //@xml:base > $(OUT)

.PHONY: clean all
clean:
	rm -rf $(BUILD_DIR)/*.xml
