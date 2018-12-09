.DELETE_ON_ERROR:
SRC:=../replica\ 1.mov
GEOM:=40x1100+310+20
FIRST:=110
LAST:=245
LAST2:=365

frames: $(SRC)
	ffmpeg -i "$^" -vf fps=30 frame%04d.jpg -hide_banner
	
FRAMES:=$(wildcard frame????.jpg)

col%.jpg: frame%.jpg
	convert $^ -crop $(GEOM) $@

SUBSET:=$(shell seq -w $(FIRST) 5 $(LAST))
SUBCOL:=$(patsubst %, col0%.jpg, $(SUBSET))

composite.jpg: $(SUBCOL)
	convert $^ +append $@

SUBSET2:=$(shell seq -w $(FIRST) $(LAST))
SUBSET3:=$(shell seq -w $(FIRST) 3 $(LAST2))
SUBCOL2:=$(patsubst %, col0%.jpg, $(SUBSET2))

bgr.jpg: $(SUBCOL2)
	convert $^ -evaluate-sequence median $@

diff%.jpg: col%.jpg bgr.jpg
	convert $^ -compose minus -composite $@

composite-diff.jpg: $(patsubst %, diff0%.jpg, $(SUBSET))
	convert $^ +append -negate $@

mean%.txt: diff%.jpg
	convert $^ -channel Y -separate -compress none -depth 8 PGM:- | \
		awk 'NR>4 {x=0; for(i=1;i<=NF;i++) {x+=$$i}; print int(x/NF)}' > $@

median%.txt: diff%.jpg
	convert $^ -channel Y -separate -compress none -depth 8 PGM:- | \
		gawk 'NR>4 {split($$0,b); asort(b,a); print a[int(NF/2)]}' > $@

max%.txt: diff%.jpg
	convert $^ -channel Y -separate -compress none -depth 8 PGM:- | \
		awk 'NR>4 {x=0; for(i=1;i<=NF;i++) {if(x<$$i) x=$$i}; print x}' > $@

mean.tsv: $(patsubst %, mean0%.txt, $(SUBSET2))
	paste $^ > $@

median.tsv: $(patsubst %, median0%.txt, $(SUBSET2))
	paste $^ > $@

max.tsv: $(patsubst %, max0%.txt, $(SUBSET2))
	paste $^ > $@

files.js:
	ls frame0*.jpg | \
		awk 'BEGIN{print "filenames=["} {print "\""$$1"\","} END{print "];"}' > $@

clean:
	rm -f $(patsubst %, max0%.txt, $(SUBSET2))
	rm -f $(patsubst %, mean0%.txt, $(SUBSET2))
	rm -f $(patsubst %, median0%.txt, $(SUBSET))
	rm -f $(patsubst %, diff0%.jpg, $(SUBSET))
	rm -f $(SUBCOL)
	rm -f $(FRAMES)
