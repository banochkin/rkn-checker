#!/bin/bash

cd "$(dirname "$0")"

bold=$(tput bold)
normal=$(tput sgr0)

token=$(head -1 "settings.conf")
userId=$(tail -1 "settings.conf")

getSites() {
    sites=()
    while IFS= read -r line || [[ -n "$line" ]]
    do
        sites+=("$line")
    done < "$1"
}

if [ -n "$1" ]; then
    sitesFile=$1
else
    sitesFile="sites.txt"
fi

sendToTelegram() {
    if [ $i -ge 1 ]; then
        curl -s $url > /dev/null
    fi
}

getSites "$sitesFile"

echo "Getting dump.csv"
wget -q --show-progress -O dump.csv https://raw.githubusercontent.com/zapret-info/z-i/master/dump.csv
echo "${bold}Done${normal}"

bannedsites="⛔ Banned sites:%0A"
i=0

echo
echo "${bold}Results:${normal}"

for site in "${sites[@]}"; do
    if grep -q "$site" dump.csv; then
        ((i=i+1))
        bannedsites="$bannedsites$i. $site%0A"
        echo "$site — ${bold}banned${normal}"
    else
        echo "$site — ok"
    fi
done

echo
echo "${bold}Banned: $i${normal}"
echo
echo "About rkn-checker: https://banochkin.com/blog/rkn-checker/"
echo

url="https://api.telegram.org/bot${token}/sendMessage?chat_id=${userId}&text="${bannedsites}"%0AAbout rkn-checker: https://banochkin.com/blog/rkn-checker/&disable_web_page_preview=True"
url=$(echo "$url" | sed 's/ /%20/g')

md5Current="$(echo $bannedsites | md5)"
if test -f "${sitesFile}.md5"; then
    md5Old=$(cat ${sitesFile}.md5)
    if [ "$md5Old" != "$md5Current" ]; then
        echo "$md5Current" > ${sitesFile}.md5
        sendToTelegram
    fi
else
    echo "$md5Current" > ${sitesFile}.md5
    sendToTelegram
fi