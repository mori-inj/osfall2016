#!/bin/bash
#

CROSS_COMPILER=armv7l-tizen-linux-gnueabi-
CCACHE=ccache

JOBS=`grep -c processor /proc/cpuinfo`
let JOBS=${JOBS}*2
JOBS="-j${JOBS}"
BOOT_PATH="arch/arm/boot"
ZIMAGE="zImage"
DZIMAGE="dzImage"

INPUT_STR=${1}
CONFIG_STR=${INPUT_STR%_smk_dis*}
#CONFIG_STR=${INPUT_STR%_tima_en*}
OPTION_STR=${INPUT_STR#*${CONFIG_STR}}

INPUT_STR2=${2}
echo "defconfig : ${CONFIG_STR}_defconfig , option : ${OPTION_STR}, Release : ${INPUT_STR2}"

if [ "${OPTION_STR}" = "_smk_dis" ]; then
	echo "Now change smack-disable for ${CONFIG_STR}_defconfig"

	sed -i 's/CONFIG_SECURITY_SMACK=y/\# CONFIG_SECURITY_SMACK is not set/g' arch/arm/configs/${CONFIG_STR}_defconfig
	if [ "$?" != "0" ]; then
		echo "Failed to change smack-disable step 1"
		exit 1
	fi

	sed -i 's/\# CONFIG_DEFAULT_SECURITY_DAC is not set/CONFIG_DEFAULT_SECURITY_DAC=y/g' arch/arm/configs/${CONFIG_STR}_defconfig
	if [ "$?" != "0" ]; then
		echo "Failed to change smack-disable step 2"
		exit 1
	fi

	sed -i 's/CONFIG_DEFAULT_SECURITY_SMACK=y/\# CONFIG_DEFAULT_SECURITY_SMACK is not set/g' arch/arm/configs/${CONFIG_STR}_defconfig
	if [ "$?" != "0" ]; then
		echo "Failed to change smack-disable step 3"
		exit 1
	fi

	sed -i 's/CONFIG_DEFAULT_SECURITY="smack"/CONFIG_DEFAULT_SECURITY=""/g' arch/arm/configs/${CONFIG_STR}_defconfig
	if [ "$?" != "0" ]; then
		echo "Failed to change smack-disable step 4"
		exit 1
	fi
fi

if [ "${OPTION_STR}" = "_tima_en" ]; then
	echo "Now change tima enable for ${CONFIG_STR}_defconfig"

	sed -i 's/\# CONFIG_TIMA is not set/CONFIG_TIMA=y/g' arch/arm/configs/${CONFIG_STR}_defconfig
	if [ "$?" != "0" ]; then
		echo "Failed to change tima enable step 1"
		exit 1
	fi

	sed -i 's/\# CONFIG_TIMA_LOG is not set/CONFIG_TIMA_LOG=y/g' arch/arm/configs/${CONFIG_STR}_defconfig
	if [ "$?" != "0" ]; then
		echo "Failed to change tima enable step 2"
		exit 1
	fi
fi

if [ "${INPUT_STR2}" = "USR" ]; then
	echo "Now disable CONFIG_SLP_KERNEL_ENG for ${CONFIG_STR}_defconfig"

	sed -i 's/CONFIG_SLP_KERNEL_ENG=y/\# CONFIG_SLP_KERNEL_ENG is not set/g' arch/arm/configs/${CONFIG_STR}_defconfig
	if [ "$?" != "0" ]; then
		echo "Failed to disable CONFIG_SLP_KERNEL_ENG feature"
		exit 1
	fi
fi

make ARCH=arm ${CONFIG_STR}_defconfig
if [ "$?" != "0" ]; then
	echo "Failed to make defconfig"
	exit 1
fi

#make $JOBS zImage ARCH=arm
make $JOBS zImage ARCH=arm CROSS_COMPILE="$CCACHE $CROSS_COMPILER"
if [ "$?" != "0" ]; then
        echo "Failed to make zImage"
        exit 1
fi

DTC_PATH="scripts/dtc/"

rm $BOOT_PATH/dts/*.dtb -f

#make ARCH=arm dtbs
make ARCH=arm dtbs CROSS_COMPILE="$CROSS_COMPILER"
if [ "$?" != "0" ]; then
        echo "Failed to make dtbs"
        exit 1
fi

dtbtool -o $BOOT_PATH/merged-dtb -p $DTC_PATH -v $BOOT_PATH/dts/
if [ "$?" != "0" ]; then
	echo "Failed to make merged-dtb"
	exit 1
fi

mkdzimage -o $BOOT_PATH/$DZIMAGE -k $BOOT_PATH/zImage -d $BOOT_PATH/merged-dtb
if [ "$?" != "0" ]; then
	echo "Failed to make mkdzImage"
	exit 1
fi

cp $BOOT_PATH/$DZIMAGE ./
tar cvf system_kernel.tar $DZIMAGE
rm -f $DZIMAGE
