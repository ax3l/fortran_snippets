#!/bin/bash
#
# Convert the Makefile dependency syntax to
# the dot file syntax.
#
# See: www.graphviz.org/pdf/dotguide.pdf
#
# Author: Axel Huebl
# Date:   March 12th, 2013
#

infile=$1

# file exitsts?
#
if [ ! -e "$infile" ]; then
  echo "usage: $0 infile.mk"
  exit 1
fi

# header
#
echo "digraph G {"

# - separate in two columns: before and after the ":"
# - print for each column before the ":" again all the
#   ones afterwards
awk -F: \
  '{ split($1,l," ");
     split($2,r," ");
     for (j in l) {
       # just the .mod file
       if (l[j] ~ /.mod/) {
         for (i in r) { 
           if (r[i] ~ /.mod/) {
             print "\""l[j]"\" -> \""r[i]"\";"
           }
         }
       }
     }
     #print $1" --- "$2
     #print l[1]
   }' $infile

# footer
#
echo "}"

