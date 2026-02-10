#!/bin/zsh
PAGE="https://articexploit.xyz/ring/"
DOMAIN="https://articexploit.xyz"

curl -s "$PAGE" \
| pup 'img attr{src}' \
| while read url; do
    if [[ "$url" =~ ^http ]]; then
        full="$url"
    elif [[ "$url" =~ ^/ ]]; then
        full="$DOMAIN$url"
    else
        full="$PAGE$url"
    fi

    fname=$(basename "${full%%\?*}")
    echo "Downloading $full"
    curl -L "$full" -o "$fname"
done
