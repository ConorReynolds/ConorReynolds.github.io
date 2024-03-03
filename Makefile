POLLEN := raco pollen
HTML_SRC := index.ptree auxiliary.ptree
PORT := 8080

export PROJECT_ROOT = ${CURDIR}

RENDER := $(POLLEN) render
SERVE := $(POLLEN) start
PUBLISH := $(POLLEN) publish
PUB_LOCATION := ${HOME}/projects/webpage-public


html:
	$(RENDER) $(HTML_SRC)

clean:
	$(POLLEN) reset
	find . -name "*.html" -type f -delete

serve:
	@(trap 'kill 0' SIGINT; \
		sass --watch styles/main.scss main.css & \
		$(SERVE) . $(PORT))

scss: styles/*.scss
	sass --style=compressed --no-source-map styles/main.scss main.css

publish: clean html scss
	$(PUBLISH) . $(PUB_LOCATION)
	rm -f $(PUB_LOCATION)/posts/draft* \
		$(PUB_LOCATION)/resources/draft*

	rm -rf $(PUB_LOCATION)/.vscode/ \
		$(PUB_LOCATION)/src/ \
		$(PUB_LOCATION)/anki/ \
		$(PUB_LOCATION)/.gitattributes \
		$(PUB_LOCATION)/references.* \
		$(PUB_LOCATION)/pygments \
		$(PUB_LOCATION)/zotero.key
	gh-pages -d $(PUB_LOCATION)/

