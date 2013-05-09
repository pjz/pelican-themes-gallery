
INDEXFILE:=$(shell pwd)/index.html

CHECKOUT=/tmp/pelican-theme-checkout
LINKBASE=http://github.com/getpelican/pelican-themes/tree/master/

build: $(INDEXFILE)

$(INDEXFILE): $(CHECKOUT)
	@echo updating $(CHECKOUT)
	@cd $(CHECKOUT) && git pull && git submodule update --recursive
	@echo creating gallery
	@for f in `find $(CHECKOUT) -name screenshot.png` ; do \
		fulldir=`dirname $$f`;\
		DIR=`basename $$fulldir` ;\
		echo "<h1><a href=\"$(LINKBASE)$$DIR\">$$DIR</a></h1>" >>$(INDEXFILE) ;\
		cp $$f $$DIR.png ;\
		echo "<img src=\"$$DIR.png\" />" >>$(INDEXFILE) ;\
		echo "<hr />" >>$(INDEXFILE) ;\
	done

$(CHECKOUT):
	@echo checking out themes to $(CHECKOUT)
	@git clone git://github.com/getpelican/pelican-themes.git $(CHECKOUT)

clean:
	rm -f $(INDEXFILE) *.png

veryclean: clean
	rm -rf $(CHECKOUT)

.PHONY: build
