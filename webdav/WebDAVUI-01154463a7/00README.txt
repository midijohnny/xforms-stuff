# TL;DR

$ make
$ cd bld
$ ./startup.sh
$ browse http://localhost:8080/main.html

##  Required tools:

- PHP 8.x*
- Composer*

(*Only needed to provide a WebDAV server; if you already have one, you can just use that.)

- Make
- XSLTForms 1.7 (Other XForms engines may work; note there is a small amount of custom JS)
- xmllint (or another tool to perform 'xinclude')
- xsltproc (or another version1.0 XSLT engine)
- XMLStarlet (optional, just cleans up the namespace definitions).
