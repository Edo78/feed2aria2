#!/bin/bash
curdir=$( dirname "${BASH_SOURCE[0]}" )

. $curdir/feed2aria2.rc
#. ./f2a2.conf

sqlfile=$(mktemp)
exec 6>&1
exec > $sqlfile
echo "begin transaction;"
for uri in $(rsstail -u $feed -l1 | grep '^Link' | cut -f 2- -d ' ')
do
    echo "insert or ignore into links(uri) values('$uri');"
done
echo "commit transaction;"
sqlite3 $curdir/$db < $sqlfile
rm $sqlfile
exec 1>&6 6>&-

for params in $(sqlite3 $curdir/$db 'select id,uri from links where completed=0;')
do
    gid=$(echo $params | cut -f 1 -d \|)
    downloaduri=$(echo $params | cut -f 2 -d \|)
    curl -H 'Content-Type: application/json' -H 'Accept:application/json' --data '{ "jsonrpc": "2.0", "id": "jsonrpcid", "method": "aria2.addUri", "params": ["token:thisisthedefaultsecrettokenwithlettersandnumberslike123",["'$downloaduri'"], {"gid":"'$(printf %016x $gid)'"}]}' http://localhost:6800/jsonrpc
    echo
done
