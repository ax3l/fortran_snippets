#!/bin/bash
#
# Pick a single module and remove or color it.
#
# Author: Axel Huebl
# Date:   March 12th, 2013
#

infile=$1

# file exitsts?
#
if [ ! -e "$infile" ]; then
  echo "usage: $0 infile.dot"
  exit 1
fi

# find files which depend on something
#
awk -F' -> ' '{print $1}' $infile | sed 's/;//g' | sort | uniq > tmp_files.dat

cp $infile $infile.tmp
for f in `cat tmp_files.dat`
do
  cp $infile.tmp $infile.tmp2

  echo "$f: [c]olor, [r]emove, [n]othing?"
  read -p "  " -n 1 -r
  if [[ $REPLY =~ ^[Cc]$ ]]
  then
    sed s/"$f;"/"$f \[style\=bold,color\=red\];"/g $infile.tmp2 > $infile.tmp
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
