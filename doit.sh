#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PARA_DDRINIT="${SCRIPT_DIR}/usbbl2runpara_ddrinit.bin"
PARA_RUNFIPIMG="${SCRIPT_DIR}/usbbl2runpara_runfipimg.bin"

PARA_ADDR=0xd900c000

SPL_ADDR=0xd9000000
SPL_FILE=${1:-output/u-boot.bin.usb.bl2}

TPL_ADDR=0x200c000
TPL_FILE=${2:-output/u-boot.bin.usb.tpl}

echo "using SPL_FILE=${SPL_FILE}"
echo "using TPL_FILE=${TPL_FILE}"

aml_usb_update_tool identify 

echo "-- DDR init --"
aml_usb_update_tool cwr "${SPL_FILE}" $SPL_ADDR
aml_usb_update_tool write "${PARA_DDRINIT}" $PARA_ADDR
aml_usb_update_tool run $SPL_ADDR

echo "-- run uboot --"
aml_usb_update_tool write "${SPL_FILE}" $SPL_ADDR
aml_usb_update_tool write "${TPL_FILE}" $TPL_ADDR
aml_usb_update_tool write "${PARA_RUNFIPIMG}" $PARA_ADDR
aml_usb_update_tool run $SPL_ADDR

