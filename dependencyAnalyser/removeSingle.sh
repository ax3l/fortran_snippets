#!/bin/bash
#
# Remove single end points, which are often used
# but uncritical in sense of "dependencies".
#
# Author: Axel Huebl
# Date:   March 12th, 2013
#

#interactive=false

infile=$1

# file exitsts?
#
if [ ! -e "$infile" ]; then
  echo "usage: $0 infile.dot"
  exit 1
fi

# find files which someone depends on
#
awk -F' -> ' '{print $2}' $infile | sed 's/;//g' | sort | uniq > tmp_files.dat

# find "referenced only" files
#
cp $infile $infile.tmp
for f in `cat tmp_files.dat`
do
  c=`grep "^$f" $infile.tmp | wc -l`
  #echo "$f: $c"

  if [ $c -lt 1 ]; then
    cp $infile.tmp $infile.tmp2

    if [ ! "$interactive" == "false" ]
    then
      echo "Remove $f with < 1 dependencies?"
    fi
    
    finished=0
    while [ "$finished" -eq "0" ]
    do
      if [ ! "$interactive" == "false" ]
      then
        read -p "  " -n 1 -r
      fi
      if [[ $REPLY =~ ^[Yy]$ || "$interactive" == "false" ]] 
      then
        grep -v "$f" $infile.tmp2 > $infile.tmp
        echo "$f removed from graph"
        finished=1
      fi
      if [[ $REPLY =~ ^[Nn]$ ]]
      then
        echo "$f keeped"
        finished=1
      fi
    done
  fi
done

# add header again
#
#echo "digraph G {" > $infile

#cat $infile.tmp >> $infile
# remove doubled lines
#
awk '!x[$0]++' $infile.tmp > $infile
#cp $infile.tmp $infile

# add footer again
#
#echo "}" >> $infile

# clean up
#
rm -rf tmp_files.dat
rm -rf $infile.tmp2
rm -rf $infile.tmp
