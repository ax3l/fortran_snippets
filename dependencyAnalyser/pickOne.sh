#!/bin/bash
#
# Pick a single module and remove or color it.
#
# Author: Axel Huebl
# Date:   March 12th, 2013
#

infile=$1
color="red"

# file exitsts?
#
if [ ! -e "$infile" ]; then
  echo "usage: $0 infile.dot"
  exit 1
fi

# find files which someone depends on
#
awk -F' -> ' '{print $2}' $infile | sed 's/;//g' | sort | uniq > tmp_files.dat

cp $infile $infile.tmp
for f in `cat tmp_files.dat`
do
  cp $infile.tmp $infile.tmp2

  echo "$f: [c]olor, [r]emove, [n]othing?"
  read -p "  " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Cc]$ ]]
  then
    # add coloring for the node (only first "..." -> "..." occurence)
    first=`grep -m1 "$f" $infile.tmp`
    sed 0,/"$first"/s//"$f \[style\=bold,color\=$color\];\n$first"/ $infile.tmp2 > $infile.tmp

    # color each edge to the destination
    cp $infile.tmp $infile.tmp2
    sed s/"$f;"/"$f \[style\=bold,color\=$color\];"/g $infile.tmp2 > $infile.tmp
  fi
  if [[ $REPLY =~ ^[Rr]$ ]]
  then
    grep -v "$f" $infile.tmp2 > $infile.tmp
    echo "$f removed from graph"
  fi
  
done

mv $infile.tmp  $infile

# clean up
#
rm -rf tmp_files.dat
rm -rf $infile.tmp2
