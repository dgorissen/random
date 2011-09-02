#!/bin/bash

# Count the number of color / B&W pages in a pdf
# usage: ./countColorPages.sh /path/to/file.pdf

infile=$1
prefix=tmp-page

# clean up
rm -f $prefix*p?m
rm output.txt

# convert pages to raster images
gs -sDEVICE=ppmraw -r30 -sOutputFile=$prefix%03d.ppm -dNOPAUSE -dBATCH -q "$infile"

for img in $prefix???.ppm ; do   # for each page
   ppmtopgm $img > $img.pgm                  # convert to grayscale
   pgmtoppm '#fff' $img.pgm > $img.pgm.ppm   # convert back to RGB
   count=`pnmpsnr $img $img.pgm.ppm 2>&1 | grep -v "No such" | grep "differ" | wc -l` 

   if [[ "$count" = "0" ]] ; then 
      echo $img " - COLOR" >> output.txt
   else
      echo $img " - BW" >> output.txt
   fi
done

echo `cat output.txt | grep COLOR | wc -l` "colored pages"
echo `cat output.txt | grep BW | wc -l` "black and white pages"

echo "The colored pages are: "
cat output.txt | grep COLOR | tr -cd '[[:digit:]]|\n'
