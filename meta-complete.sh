#!/bin/bash
echo "Called with [$1] [$2] [$3]" >> /share/Public/meta-completed.txt
if [ $2 -eq 0 ]
then
    gid=$(curl -H 'Content-Type: application/json' -H 'Accept:application/json' --data '{ "jsonrpc": "2.0", "id": "qwer", "method": "aria2.tellStatus", "params": ["token:thisisthedefaultsecrettokenwithlettersandnumberslike123","'$1'",["followedBy"]]}' http://localhost:6800/jsonrpc 2>/dev/null | cut -f 14 -d \")
    sqlite3 -init <(echo .timeout 5000) /share/devel/feed2aria2/feedlinks.db "update links set gid='$gid' where id=$(printf "%d" 0x$1)"
    curl -H 'Content-Type: application/json' -H 'Accept:application/json' --data '{ "jsonrpc": "2.0", "id": "qwer", "method": "aria2.removeDownloadResult", "params": ["token:thisisthedefaultsecrettokenwithlettersandnumberslike123","'$1'"]}' http://localhost:6800/jsonrpc
fi
