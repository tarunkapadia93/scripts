#!/bin/bash

# Colorize and add text parameters
grn=$(tput setaf 2)             #  green
txtbld=$(tput bold)             # Bold
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

DEVICE="$1"
MODE="$2"

# Time of build startup
res1=$(date +%s.%N)

# Reading mode
if [ ! -z $MODE ]; then
    if [ $MODE == "c" ]; then
       echo -e "${bldblu}Cleaning up out folder ${txtrst}"
       make clobber;
    fi
else
	echo -e "${bldblu}Dirty Clean up out folder ${txtrst}"
        make installclean
fi

# Setup environment
echo -e "${bldblu}Setting up build environment ${txtrst}"
. build/envsetup.sh

# Setup ccache
export USE_CCACHE=1
/usr/bin/ccache -M 50G

# GRADLE APPS SKIP
export SKIP_GRADLE_APP_BUILDS=true

# Prebuilt chromium
export USE_PREBUILT_CHROMIUM=1

# Lunch device
echo -e "${bldblu}Lunching device... ${txtrst}"
lunch "nameless_$DEVICE-userdebug"

# Remove previous build info
echo -e "${bldblu}Removing previous build.prop ${txtrst}"
rm $OUT/system/build.prop;

# Start compilation
echo -e "${bldblu}Starting build for $DEVICE ${txtrst}"
mka bacon

# Get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
