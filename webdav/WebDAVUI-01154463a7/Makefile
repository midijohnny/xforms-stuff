.PHONY: all composer php dirs copy-xsltforms build-xforms

all: build-xforms

composer:
	(cd src/php; composer install)

php: composer
	rsync -a --delete src/php/ bld/

copy-css: dirs
	cp -r src/css/ bld/public

copy-js: dirs
	cp -r src/js/ bld/public

dirs: php
	mkdir -p bld/data bld/public bld/public/css bld/public/js
	mkdir -p bld/public/folder1/folder2/folder3
	cp -r src bld/public
	chmod -R a+rwx bld/data bld/public

copy-xsltforms: dirs
	cp -r ../../xsltforms-1.7 bld/public/

build-xforms: copy-xsltforms copy-css copy-js
	./build.sh

clean:
	rm -rf bld/*
