POLLEN := raco pollen
HTML_SRC := index.ptree auxiliary.ptree
SERVE_DIR := .
DST := build/
PORT := 8080

RENDER := $(POLLEN) render
SERVE := $(POLLEN) start
PUBLISH := $(POLLEN) publish
PUB_LOCATION := ../projects/webpage-public


scss: styles/*.scss
	sass styles/main.scss main.css

html: scss
	$(RENDER) $(HTML_SRC)

publish: html scss
	$(PUBLISH) . $(PUB_LOCATION)
	rm -rf $(PUB_LOCATION)/.vscode/ \
		$(PUB_LOCATION)/src/ \
		$(PUB_LOCATION)/.gitattributes \
		$(PUB_LOCATION)/monochrome.py \
		$(PUB_LOCATION)/zotero.key
	gh-pages -d $(PUB_LOCATION)/

serve:
	$(SERVE) $(SERVE_DIR) $(PORT)

clean:
	$(POLLEN) reset

sasswatch: styles/*.scss
	sass --watch styles/main.scss main.css
