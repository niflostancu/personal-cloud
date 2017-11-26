#!/bin/bash
# 
# Seafile installation / upgrade check script
# Checks whether Seafile is correctly installed and configured before starting it.
# Also checks whether the installed version is equal to the image-bundled version.
# If not, it will be automatically upgraded.

set -e

IMAGE_SEAFILE_VERSION=`cat /opt/seafile/version`
VERSION_FILE=".seafile-version"

if [ -t 0 ]; then
    INTERACTIVE=1
fi

source /etc/profile.d/python-local.sh   

cd $SEAFILE_HOME
mkdir -p seafile-server

# Install seahub
if [ ! -d 'seafile-server/seahub' ]; then
    mkdir -p seafile-server/seahub
	tar xzf /usr/local/share/seafile/seahub.tgz -C seafile-server/seahub
fi

# If there is $VERSION_FILE already, then it isn't first run of this script, 
#  do not need to configure seafile
if [ ! -f $VERSION_FILE ]; then
	echo 'No previous version on Seafile configurations found, starting seafile configuration...'
    
    mkdir -p "${SEAFILE_DATA_DIR}/avatars"
    mv -f "seafile-server/seahub/media/avatars/"* "${SEAFILE_DATA_DIR}/avatars"
    rm -rf "seafile-server/seahub/media/avatars"
    ln -s "${SEAFILE_DATA_DIR}/avatars" "${SEAFILE_HOME}/seafile-server/seahub/media/avatars"

    if [[ ! -d "${SEAFILE_HOME}/conf" ]] || [[ ! -d "${SEAFILE_HOME}/ccnet" ]]; then
        if [[ $INTERACTIVE -eq 1 ]]; then
            echo "Seafile is not properly configured, running the setup script..."
            python /usr/local/bin/seafile-init-mysql.py
        else
            echo "Seafile is not configured, please run the container in interactive mode!"
            exit 1
        fi
    fi

	# Keep seafile version for managing future updates
	echo -n "${SEAFILE_VERSION}" > $VERSION_FILE
	echo "Configuration completed!"

else #[ ! -f $VERSION_FILE ];
	# Need to check if we need to run upgrade scripts
	echo "Version file found in container, checking it"
	OLD_VER=`cat $VERSION_FILE`
	if [ "x$OLD_VER" != "x$SEAFILE_VERSION" ]; then
		echo "Version is different. Stored version is $OLD_VER, Current version is $SEAFILE_VERSION"
		if [ -f '.no-update' ]; then
			echo ".no-update file found, skipping update"
			echo "You should update user data manually (or delete file .no-update)"
			echo "  do not forget to update seafile version in $VERSION_FILE manually after update"
		else
			echo "No .no-update file found, performing update..."

			# upgrade seahub
			[ -e 'seafile-server/seahub' ] && mv ${SEAFILE_HOME}/seafile-server/seahub ${SEAFILE_HOME}/seafile-server/seahub.old
			mkdir -p seafile-server/seahub && \
				tar xzf /usr/local/share/seafile/seahub.tgz -C seafile-server/seahub && \
				[ -e 'seafile-server/seahub.old' ] && rm -rf ${SEAFILE_HOME}/seafile-server/seahub.old

			# Copy upgrade scripts. symlink doesn't work, unfortunatelly 
			#  and I do not want to patch all of them
			cp -rf /usr/local/share/seafile/scripts/upgrade seafile-server/
			# Get first and second numbers of versions (we do not care about last number, actually)
			OV1=`echo "$OLD_VER" | cut -d. -f1`
			OV2=`echo "$OLD_VER" | cut -d. -f2`
			#OV3=`echo "$OLD_VER" | cut -d. -f3`
			CV1=`echo "$SEAFILE_VERSION" | cut -d. -f1`
			CV2=`echo "$SEAFILE_VERSION" | cut -d. -f2`
			#CV3=`echo "$SEAFILE_VERSION" | cut -d. -f3`

			i1=$OV1
			i1p=$i1
			i2p=$OV2
			i2=`expr $i2p '+' 1`
			while [ $i1 -le $CV1 ]; do
				SCRIPT="./seafile-server/upgrade/upgrade_${i1p}.${i2p}_${i1}.${i2}.sh"
				if [ -f $SCRIPT ]; then
					echo "Executing $SCRIPT..."
					if [ $INTERACTIVE -eq 1 ]; then
						$SCRIPT
					else
						echo | $SCRIPT
					fi

					i1p=$i1
					i2p=$i2
					i2=`expr "$i2" '+' 1`
				else
					i1p=$i1
					i1=`expr "$i1" '+' 1`
					i2=0
				fi
			done

			# Run minor upgrade, just in case (Actually needed when only last number was changed)
			if [[ "$INTERACTIVE" -eq 1 ]]; then
				./seafile-server/upgrade/minor-upgrade.sh
			else
				echo | ./seafile-server/upgrade/minor-upgrade.sh
			fi

			rm -rf seafile-server/upgrade
			echo -n "${SEAFILE_VERSION}" > $VERSION_FILE
		fi
	else
		echo "Version is the same, no upgrade needed"
	fi
fi

