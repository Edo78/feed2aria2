#!/bin/sh

. ./feed2aria2.rc
. ./f2a2.conf

sqlfile=$(mktemp)
exec > $sqlfile
echo "begin transaction;"
for uri in $(rsstail -u $feed -l1 | grep '^Link' | cut -f 2- -d ' ')
do
    echo "insert or ignore into links(uri) values('$uri');"
done
echo "commit transaction;"
sqlite3 $db < $sqlfile
rm $sqlfile

for downloaduri in $(sqlite3 feedlinks.db 'select uri from links where completed=0;')
do
    curl -H 'Content-Type: application/json' -H 'Accept:application/json' --data '{ "jsonrpc": "2.0", "id": "qwer", "method": "aria2.addUri", "params": ["token:thisisthedefaultsecrettokenwithlettersandnumberslike123",["'$downloaduri'"]]}' http://10.0.0.1:6800/jsonrpc
done
