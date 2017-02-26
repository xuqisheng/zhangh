#!/bin/bash
# --------------------------------------------------------------------
# function:
#           execute sql files of a directory in designated database
# usages  :
#           ./updatedb.sh <directory> <dbname>
# e.g.    :
#           ./updatedb.sh /root/mode/sql/0.basic/1.create_index portal
# --------------------------------------------------------------------

#

/root/mode/modelog "$0 $*"

#

. /root/mode/mysqldip 

[ -z "$1" ] && exit 
[ -z "$2" ] && exit 

#

find -L "$1" -name "*.sql" | sed -re "s/\.sql$//" | sort | sed -re "s/$/.sql/" | while read -r i; do
   echo "`date +%Y-%m-%d\ %H:%M:%S` $i"
   /root/mode/seecfg $HMYSQLDIP "$i" "$2" 2>&1 | tee /root/mode/tmp/hupdatedb$$.tmp 
   [ `cat /root/mode/tmp/hupdatedb$$.tmp | wc -l` -gt 0 ] && echo
done
rm -f /root/mode/tmp/hupdatedb$$.tmp

#

