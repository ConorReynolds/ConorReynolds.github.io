# Make sure to `make` everything before publishing!

DST := build

LATEX := latexmk
LATEX_ARGS := -synctex=1 -interaction=nonstopmode -shell-escape -file-line-error -pdflua -outdir=$(DST)

html:
	raco pollen render index.ptree

serve: html
	hugo server

latex:
	raco pollen render tex.ptree
	$(LATEX) $(LATEX_ARGS) content/posts/*.tex
	cp $(DST)/*.pdf content/posts

pdf: latex
	raco pollen render pdf.ptree

all: html latex
