#!/bin/sh
~/work/basex/bin/basex -bsource_url=TEST.xml lcp-qaqc.xq > out.html && google-chrome-stable out.html