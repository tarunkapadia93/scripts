#!/bin/bash

# Colorize and add text parameters
grn=$(tput setaf 2)             #  green
txtbld=$(tput bold)             # Bold
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
txtrst=$(tput sgr0)             # Reset

KERNEL_DIR=~/kernel
KERNEL_OUT=~/kernel/zip/kernel_zip

#Clean the build
echo -n "${bldblu} Do you wanna clean the build (y/n)? ${txtrst}"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo -e "${bldgrn} Cleaning the old build ${txtrst}"
make mrproper
rm -rf $KERNEL_OUT/dtb
rm -rf $KERNEL_OUT/zImage
rm -rf $KERNEL_OUT/../*.zip
fi

echo -e "${bldgrn} Setting up Build Environment ${txtrst}"
export KBUILD_BUILD_USER="Tarun93"
export KBUILD_BUILD_HOST="TEST_CARBON_KERNEL"
export ARCH=arm
#export CROSS_COMPILE=~/toolchains/Sabermod-arm-eabi-5.2/bin/arm-eabi-
export CROSS_COMPILE=~/toolchains/UBERTC-arm-eabi-4.9/bin/arm-eabi-
export USE_CCACHE=1
/usr/bin/ccache -M 25G


echo -e "${bldgrn} Building Defconfig ${txtrst}"
make cyanogenmod_armani_defconfig 

echo -n "${bldblu}Do you wanna make changes in the defconfig (y/n)? ${txtrst}"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo -e "${bldgrn} Building Defconfig GUI ${txtrst}"
make menuconfig

echo -n "${bldblu}Do you wanna save the changes in the defconfig (y/n)? ${txtrst}"
read answer
if echo "$answer" | grep -iq "^y" ;then
    echo -e "${bldgrn} Building Defconfig GUI ${txtrst}"
cp -f .config $KERNEL_DIR/arch/arm/configs/cyanogenmod_armani_defconfig
fi
fi

echo -e "${bldgrn}.....................................................................${txtrst}"
echo -e "${bldgrn}...................${bldblu}STARTING.CARBON.KERNEL.BUILD${bldgrn}......................${txtrst}"
echo -e "${bldgrn}.....................................................................${txtrst}"
make -j12
mv $KERNEL_DIR/arch/arm/boot/zImage  $KERNEL_OUT/zImage

if ! [ -a  $KERNEL_OUT/zImage ];
then
echo -e "${bldblu} Kernel Compilation failed! Fix the errors! ${txtrst}"
exit 1
fi

echo -e "${bldgrn} DTB Build  ${txtrst}"
./dtbToolCM -2 -o $KERNEL_OUT/dtb -s 2048 -p scripts/dtc/ arch/arm/boot/

if ! [ -a $KERNEL_OUT/dtb ];
then
echo -e "${bldblu} Kernel Compilation failed! Fix the errors! ${txtrst}"
exit 1
fi


echo -e "${bldgrn} Zipping the Kernel Build  ${txtrst}"
cd $KERNEL_OUT/
zip -r ../CARBON_KERNEL_$(date +%d%m%Y_%H%M) .
cd $KERNEL_DIR
