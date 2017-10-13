#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BOOTIT_FILE="${1:-${PWD}/.bootit}"

#-- default settings, will be overwritten with settings in "${BOOTIT_FILE}" --
PARA_DDRINIT="${SCRIPT_DIR}/usbbl2runpara_ddrinit.bin"
PARA_RUNFIPIMG="${SCRIPT_DIR}/usbbl2runpara_runfipimg.bin"

PARA_ADDR=0xd900c000
SPL_ADDR=0xd9000000
TPL_ADDR=0x200c000

KERNEL_ADDR=0x1080000
INITRD_ADDR=0x20000000
DTB_ADDR=0x1070000
SD_ADDR=0x30000000

# Maiinline U-Boot only:
# This is the U-Boot script address it is defined in 
# u-boot/configs/meson-gxbb-common.h
# Be careful not to overwrite the script in memory when writing the kernel, etc.
UBOOT_SCR_ADDR=0x1f000000

SPL_FILE="${SCRIPT_DIR}/boot/u-boot.bin.usb.bl2"
TPL_FILE="${SCRIPT_DIR}/boot/u-boot.bin.usb.tpl"
SD_FILE="${SCRIPT_DIR}/boot/u-boot.bin.sd.bin"

KERNEL="${SCRIPT_DIR}/default/Image"
INITRD="${SCRIPT_DIR}/default/rootfs.cpio.uboot"
DTB="${SCRIPT_DIR}/default/gxl_p230_1g.dtb"
UBOOT_SCR="${SCRIPT_DIR}/default/u-boot.scr"
#-----------------------------------------------------------------------------

#-- toobox -------------------------------------------------------------------
function fatal() {
    echo -e "${@}" && exit 1
}

function require_file() {
    for f in "${@}"; do
        echo -n "checking for $f: "
        ! [[ -f "$f" ]] && fatal "ERROR: $f not found"
        echo "OK"
    done
}

function expect_output() {
    local EXPECTED="$1"
    shift

    local OUTPUT="$(echo $( ${@} ))"

    [[ "${OUTPUT}" == "${EXPECTED}" ]]
}
#-----------------------------------------------------------------------------

echo -e "## bootit.sh\n"

[[ -f "${BOOTIT_FILE}" ]] && echo "sourcing ${BOOTIT_FILE}" && source "${BOOTIT_FILE}"


require_file "${KERNEL}" "${INITRD}" "${DTB}" "${SPL_FILE}" "${TPL_FILE}" "${UBOOT_SCR}"

! expect_output "AmlUsbIdentifyHost This firmware version is 2-2-0-0" "${SCRIPT_DIR}/update" identify && \
fatal "ERROR: no device found"

#${SCRIPT_DIR}/update wreg 0x1b8ec003 0xc88345c8
#echo "Press ENTER to continue"
#read

echo "-- DDR init --"
${SCRIPT_DIR}/update cwr "${SPL_FILE}" $SPL_ADDR
${SCRIPT_DIR}/update write "${PARA_DDRINIT}" $PARA_ADDR
${SCRIPT_DIR}/update run $SPL_ADDR

sleep 1

echo "-- run uboot --"

echo "uploading kernel ${KERNEL} to address ${KERNEL_ADDR}"
${SCRIPT_DIR}/update write "${KERNEL}" "${KERNEL_ADDR}"

echo "uploading initrd ${INITRD} to address ${INITRD_ADDR}"
${SCRIPT_DIR}/update write "${INITRD}" "${INITRD_ADDR}"
#
echo "uploading dtb ${DTB} to address ${DTB_ADDR}"
${SCRIPT_DIR}/update write "${DTB}" "${DTB_ADDR}"
#
echo "uploading u-boot script ${UBOOT_SCR} to address ${UBOOT_SCR_ADDR}"
${SCRIPT_DIR}/update write "${UBOOT_SCR}" "${UBOOT_SCR_ADDR}"

echo "uploading u-boot sd card image script ${SD_FILE} to address ${SD_ADDR}"
${SCRIPT_DIR}/update write "${SD_FILE}" "${SD_ADDR}"


echo uploading spl
${SCRIPT_DIR}/update write "${SPL_FILE}" $SPL_ADDR && \
echo uploading tpl
${SCRIPT_DIR}/update write "${TPL_FILE}" $TPL_ADDR && \
echo uploading para
${SCRIPT_DIR}/update write "${PARA_RUNFIPIMG}" $PARA_ADDR && \
echo boot!
${SCRIPT_DIR}/update run $SPL_ADDR

sleep 3
#${SCRIPT_DIR}/update bulkcmd "booti ${KERNEL_ADDR} ${INITRD_ADDR} ${DTB_ADDR}"
