# ----------
#  Makefile
# 
#       Makefile for GracefulPSU
# 
#       Copyright (c) 2023 Marc Munro
# 	License: GPL-3.0
#  
#  ----------
#
# Makefile for creating html versions of markdown files for
# proof-reading and correctness checking.


.PHONY: clean tidy docs psu_doc readme

# Define glob patterns for garbage files that clean targets should
# remove.
#
garbage := \\\#*  .\\\#*  *~ 

PANDOC = /usr/bin/pandoc

# Default target
#

docs: psu.html README.html

psu_doc: psu.html
	xdg-open psu.html

readme: README.html
	xdg-open README.html

clean: tidy
	@rm *html
	@echo "Cleanup done"

tidy:
	@rm -f ${garbage} 2>/dev/null || true


# Create html from markdown.  This enables us to test the formatting of
# markdown files.
#
%.html: %.md
	$(PANDOC) --shift-heading-level-by=-1 $*.md \
		--standalone --to=html >$*.html
