POLLEN := raco pollen
HTML_SRC := index.ptree auxiliary.ptree
SERVE_DIR := .
DST := build/
PORT := 8080

export PROJECT_ROOT = ${CURDIR}

RENDER := $(POLLEN) render
SERVE := $(POLLEN) start
PUBLISH := $(POLLEN) publish
PUB_LOCATION := ../projects/webpage-public


scss: styles/*.scss
	sass --style=compressed styles/main.scss main.css

html: scss
	$(RENDER) $(HTML_SRC)

publish: html scss
	$(PUBLISH) . $(PUB_LOCATION)
	rm -rf $(PUB_LOCATION)/.vscode/ \
		$(PUB_LOCATION)/src/ \
		$(PUB_LOCATION)/.gitattributes \
		$(PUB_LOCATION)/pygments \
		$(PUB_LOCATION)/zotero.key
	gh-pages -d $(PUB_LOCATION)/

serve:
	$(SERVE) $(SERVE_DIR) $(PORT)

clean:
	$(POLLEN) reset
	find . -name "*.html" -type f -delete

sasswatch: styles/*.scss
	sass --watch styles/main.scss main.css
