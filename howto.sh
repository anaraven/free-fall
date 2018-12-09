ffmpeg -i ../replica\ 1.mov -vf fps=30 frame%04d.jpg -hide_banner
for i in `seq -w 365`; do  convert frame0$i.jpg -crop 40x1100+310+20 col$i.jpg; done
convert `seq -w 110 5 245 |sed 's/\(.*\)/col\1.jpg/'` +append yyy.jpg
convert `seq -w 110 5 245 |sed 's/\(.*\)/col\1.jpg/'` -evaluate-sequence median bgr.jpg
for i in `seq -w 110 245`; do convert col$i.jpg bgr.jpg -compose minus -composite diff$i.jpg; done
for i in `seq -w 110 245`; do convert diff$i.jpg -channel Y -separate -compress none -depth 8 PGM:- |awk 'NR>4 {x=0; for(i=1;i<=NF;i++) {x+=$i}; print int(x/NF)}' > mean$i.txt; done
for i in `seq -w 110 245`; do convert diff$i.jpg -channel Y -separate -compress none -depth 8 PGM:- |gawk 'NR>4 {split($0,b); asort(b,a); print a[int(NF/2)]}' > median$i.txt; done
for i in `seq -w 110 245`; do convert diff$i.jpg -channel Y -separate -compress none -depth 8 PGM:- |awk 'NR>4 {x=0; for(i=1;i<=NF;i++) {if(x<$i) x=$i}; print x}' > max$i.txt; done
paste mean*.txt > mean.tsv
paste median*.txt > median.tsv
paste max*.txt > max.tsv


ls frame0* | awk 'BEGIN{print "filenames=["} {print "\""$1"\","} END{print "];"}' >files.json
open index.html
