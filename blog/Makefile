all: pdf html

pdf:
	asciidoctor-pdf -a toc *.adoc

html:
	asciidoctor -a toc *.adoc

.PHONY: all pdf html