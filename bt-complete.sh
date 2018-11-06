#!/bin/bash
echo "Called with [$1] [$2] [$3]" >> /share/Public/bt-completed.txt

sqlite3 -init <(echo .timeout 5000) /share/devel/feed2aria2/feedlinks.db "update links set completed=1 where gid='$1'"

curl -H 'Content-Type: application/json' -H 'Accept:application/json' --data '{ "jsonrpc": "2.0", "id": "qwer", "method": "aria2.removeDownloadResult", "params": ["token:thisisthedefaultsecrettokenwithlettersandnumberslike123","'$1'"]}' http://localhost:6800/jsonrpc
