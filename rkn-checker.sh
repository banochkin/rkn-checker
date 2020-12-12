#!/bin/bash

cd "$(dirname "$0")"

token=$(head -1 "settings.conf")
userId=$(tail -1 "settings.conf")

getSites() {
    sites=()
    while IFS= read -r line || [[ -n "$line" ]]
    do
        sites+=("$line")
    done < "$1"
}
getSites "sites.txt"

echo "Getting dump.csv"
wget -q -O dump.csv https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv
echo "Done"

bannedsites="⛔ Banned sites:%0A"
i=0

echo
echo "Results:"

for site in "${sites[@]}"; do
    if grep -q "$site" dump.csv; then
        ((i=i+1))
        bannedsites="$bannedsites$i. $site%0A"
        echo "$site — banned"
    else
        echo "$site — ok"
    fi
done

bannedsites="$bannedsites%0AAbout rkn-checker: https://banochkin.com/blog/rkn-checker/"

curl -s "https://api.telegram.org/bot$token/sendMessage?chat_id=$userId&text=$bannedsites" > /dev/null