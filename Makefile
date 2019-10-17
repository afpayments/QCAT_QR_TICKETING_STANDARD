adocs = \
		qr-code-ticketing-standard.adoc \
		qr-code-ticketing-settlement.adoc \
		qr-code-ticketing-key-management.adoc \
		qr-code-ticketing-risk-management.adoc \
		qr-samples.adoc

inlinedadocs = \
		qr-code-ticketing-standard-inlined.adoc \
		qr-code-ticketing-settlement-inlined.adoc \
		qr-code-ticketing-key-management-inlined.adoc \
		qr-code-ticketing-risk-management-inlined.adoc \
		qr-samples-inlined.adoc

externalpdfs = \
		build/external/qr-code-ticketing-standard-external.pdf \
		build/external/qr-code-ticketing-settlement-external.pdf \
		build/external/qr-code-ticketing-key-management-external.pdf \
		build/external/qr-code-ticketing-risk-management-external.pdf \
		build/samples/qr-samples.pdf

internalpdfs = \
		build/internal/qr-code-ticketing-standard-internal.pdf \
		build/internal/qr-code-ticketing-settlement-internal.pdf \
		build/internal/qr-code-ticketing-key-management-internal.pdf \
		build/internal/qr-code-ticketing-risk-management-internal.pdf \
		build/samples/qr-samples.pdf

externalhtmls = \
		build/external/qr-code-ticketing-standard-external.html \
		build/external/qr-code-ticketing-settlement-external.html \
		build/external/qr-code-ticketing-key-management-external.html \
		build/external/qr-code-ticketing-risk-management-external.html \
		build/samples/qr-samples.html

internalhtmls = \
		build/internal/qr-code-ticketing-standard-internal.html \
		build/internal/qr-code-ticketing-settlement-internal.html \
		build/internal/qr-code-ticketing-key-management-internal.html \
		build/internal/qr-code-ticketing-risk-management-internal.html \
		build/samples/qr-samples.html

externalzips = build/external/$(adocs:.adoc=-external.zip)
internalzips = build/internal/$(adocs:.adoc=-internal.zip)

all: internalpdf externalpdf internalhtml externalhtml
internal: internalhtml internalpdf
external: externalhtml externalpdf

internalpdf: $(internalpdfs)
externalpdf: $(externalpdfs)
internalhtml: b64 $(internalhtmls)
externalhtml: b64 $(externalhtmls)


externalzip: qr-code-ticketing-standard-external.zip
internalzip: qr-code-ticketing-standard-internal.zip
releasezip: qr-code-ticketing-standard-release.zip

build/internal/%-internal.pdf: %.adoc
	asciidoctor-pdf -a includedir="" -a internal  -a pdf-stylesdir=styles -a pdf-style=log -a imagesdir=./images/ -o build/internal/$*-internal.pdf $<

build/external/%-external.pdf: %.adoc
	asciidoctor-pdf -a includedir="" -a internal! -a pdf-stylesdir=styles -a pdf-style=log -a imagesdir=./images/ -o build/external/$*-external.pdf $<


build/internal/%-internal.html:	%.adoc
	adoc-inline-images.sh $< >build/$<
	asciidoctor -a includedir="../" -a internal -a stylesdir=../styles -a stylesheet=colony.css -a image-dir=./images/ -o build/internal/$*-internal.html build/$<
	rm build/$<

build/external/%-external.html:	%.adoc
	adoc-inline-images.sh $< >build/$<
	asciidoctor -a includedir="../" -a internal! -a stylesdir=../styles -a stylesheet=colony.css -a image-dir=./images/ -o build/external/$*-external.html build/$<
	rm build/$<

build/samples/%.pdf: samples/%.adoc
		asciidoctor-pdf -a internal  -a pdf-stylesdir=styles -a pdf-style=log -a imagesdir=images/ -o build/samples/$*.pdf $<

build/samples/%.html:	samples/%.adoc
		asciidoctor -a internal -a stylesdir=../styles -a stylesheet=colony.css -a image-dir=images/ -o build/samples/$*.html $<



%-external.zip: $(externalpdfs) $(externalhtmls)
	rm -f build/external/*.zip
	zip -r build/external/$@ $(externalpdfs) $(externalhtmls) build/external/images -x \*/.DS_Store

%-internal.zip: $(internalpdfs) $(internalhtmls)
	rm -f build/internal/*.zip
	zip -r build/internal/$@ $(internalpdfs) $(internalhtmls) build/internal/images -x \*/.DS_Store

%-release.zip: $(externalpdfs) $(externalhtmls)
	rm -f build/external/*.zip
	zip -r build/external/$@ $(externalpdfs) $(externalhtmls) -x \*/.DS_Store

images = $(wildcard images/*.png)
sampleimages = $(wildcard samples/images/*.png)

b64images = $(images:.png=.b64)

b64: $(b64images)

%.b64: %.png
	base64 -i $< -o build/$@

clean:
	rm -f build/internal/*.pdf
	rm -f build/external/*.pdf
	rm -f build/internal/*.html
	rm -f build/external/*.html
	rm -f build/internal/*.zip
	rm -f build/external/*.zip
	rm -f build/samples/*
	rm -f images/*.b64
	mkdir -p build/internal
	mkdir -p build/external
	mkdir -p build/samples
	mkdir -p build/images


# This Makefile relies on a script with the following content to be in the shells path
#
# #!/usr/local/bin/bash
#
# gawk '
#   match($0, /image::(.+)(\[.*\])/, m) {
#     gsub(/png/, "b64", m[1]);
#     printf("image::data:image/png;base64,");
#     "cat build/images/" m[1]| getline b64; printf("%s", b64);
#     print("[]"); next }
#     { print }' $1
