#!/bin/bash
# Utility script that can be used to download the latest seafile-server.
#

ARCH=$(uname -m | sed s/"_"/"-"/g)
SEAFILE_URL_REGEX="http(s?):\/\/[^ \"\(\)\<\>]*seafile-server_[\d\.\_]*$ARCH.tar.gz"

SEAFILE_URL=$(curl -Ls https://www.seafile.com/en/download/ | \
    grep -o -P "$SEAFILE_URL_REGEX" | head -1)

# download the latest archive
echo "Downloading $SEAFILE_URL ..."
curl -L -O $SEAFILE_URL || exit 1

# Returns the top level directory of an archive
function get_archive_dirname() {
    local DIR="$(tar tvf ${1} | egrep -o "[^ ]+/$")"
    if [ "$(echo ${DIR} | egrep -o " " | wc -l)" -eq 0 ]; then
        echo ${DIR};
    else
        echo "ERROR: multiple directories in tarball '$1'!"
        exit 1
    fi
}

DOWNLOADED_FILE=$( echo $SEAFILE_URL | awk -F/ '{ print $NF }' )

if [ ! -z $DOWNLOADED_FILE -a -f $DOWNLOADED_FILE ]; then
    SEAFILE_DIR=$( tar tvzf $DOWNLOADED_FILE 2>/dev/null | head -n 1 | \
        awk '{ print $NF }' | sed -e 's!/!!g')
    echo "Extracting archive..."
    tar xzf $DOWNLOADED_FILE
    echo "Done! Check $SEAFILE_DIR"

else
    echo "Invalid downloaded file ($DOWNLOADED_FILE)!"
    exit 1
fi

