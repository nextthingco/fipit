#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#------

UPDATE="${SCRIPT_DIR}/update"

BR2_PATH="$HOME/Projects/buildroot_openlinux/output/mesongxl_p230/images/"
GADGET_PATH="$HOME/Projects/gadget-os-kaplan2539/output/images/"

SPL_FILE="${SCRIPT_DIR}/default/u-boot.bin.usb.bl2"
TPL_FILE="${SCRIPT_DIR}/default/u-boot.bin.usb.tpl"

 UBOOT_IMG="${GADGET_PATH}/u-boot.bin.sd.bin"
   DTB_IMG="${GADGET_PATH}/dtb.img"
KERNEL_IMG="${GADGET_PATH}/boot.img"
ROOTFS_IMG="${GADGET_PATH}/rootfs.ext2.img2simg"

#------

PARA_DDRINIT="${SCRIPT_DIR}/usbbl2runpara_ddrinit.bin"
PARA_RUNFIPIMG="${SCRIPT_DIR}/usbbl2runpara_runfipimg.bin"

PARA_ADDR=0xd900c000

SPL_ADDR=0xd9000000

TPL_ADDR=0x200c000

KERNEL_ADDR=0x1080000
INITRD_ADDR=0x20000000
DTB_ADDR=0x1070000
UBOOTIMG_ADDR=0x10000000

#KERNEL="$HOME/Projects/gadget-os-kaplan2539/output/images/Image"
#INITRD="$HOME/Projects/gadget-os-kaplan2539/output/images/rootfs.cpio.uboot"
##DTB="$HOME/Projects/gadget-os-kaplan2539/output/images/meson-gxl-s905d-chip4.dtb"
#DTB="$HOME/Projects/gadget-os-kaplan2539/output/images/meson-gxl-s905d-p230.dtb"

#KERNEL="$HOME/Projects/linux-stable/arch/arm64/boot/Image"
#DTB="$HOME/Projects/linux-stable/arch/arm64/boot/dts/amlogic/meson-gxl-s905d-p230.dtb"
#INITRD="$HOME/Projects/gadget-os-kaplan2539/output/images/rootfs.cpio.uboot"

##KERNEL="${SCRIPT_DIR}/default/Image"
INITRD="${SCRIPT_DIR}/default/rootfs.cpio.uboot"
##DTB="${SCRIPT_DIR}/default/gxl_p230_1g.dtb"
##
  KERNEL="${BR2_PATH}/Image"
     DTB="${BR2_PATH}/gxl_p230_1g.dtb"

# ! [[ -f "$KERNEL" ]] && echo "ERROR: $KERNEL not found" && exit 1
# ! [[ -f "$INITRD" ]] && echo "ERROR: $INITRD not found" && exit 1
# ! [[ -f "$DTB" ]] && echo "ERROR: $DTB not found" && exit 1
# ! [[ -f "$UBOOTIMG" ]] && echo "ERROR: $DTB not found" && exit 1

echo "using SPL_FILE=${SPL_FILE}"
echo "using TPL_FILE=${TPL_FILE}"

${UPDATE} identify 

#${UPDATE} wreg 0x1b8ec003 0xc88345c8
#echo "Press ENTER to continue"
#read

echo "-- DDR init --"
${UPDATE} cwr "${SPL_FILE}" $SPL_ADDR
${UPDATE} write "${PARA_DDRINIT}" $PARA_ADDR
${UPDATE} run $SPL_ADDR

sleep 1

echo "-- run uboot --"

#echo "uploading u-boot img ${UBOOTIMG} to address ${UBOOTIMG_ADDR}"
#${UPDATE} write "${UBOOTIMG}" "${UBOOTIMG_ADDR}" && \

#echo "uploading kernel ${KERNEL} to address ${KERNEL_ADDR}"
#${UPDATE} write "${KERNEL}" "${KERNEL_ADDR}" && \
#echo uploading initrd
#${UPDATE} write "${INITRD}" "${INITRD_ADDR}" && \
#echo uploading dtb
#${UPDATE} write "${DTB}" "${DTB_ADDR}" && \

echo uploading spl
${UPDATE} write "${SPL_FILE}" $SPL_ADDR && \
echo uploading tpl
${UPDATE} write "${TPL_FILE}" $TPL_ADDR && \
echo uploading para
${UPDATE} write "${PARA_RUNFIPIMG}" $PARA_ADDR && \
echo boot!
${UPDATE} run $SPL_ADDR

sleep 3
${UPDATE} mwrite "${DTB_IMG}" mem dtb normal
${UPDATE} bulkcmd "disk_initial 1"

${UPDATE} partition boot       "${KERNEL_IMG}" normal
${UPDATE} partition _aml_dtb   "${DTB_IMG}"    normal
${UPDATE} partition system     "${ROOTFS_IMG}" sparse
${UPDATE} partition bootloader "${UBOOT_IMG}"   normal

${UPDATE} bulkcmd "save_setting"

#${UPDATE} bulkcmd "booti ${KERNEL_ADDR} ${INITRD_ADDR} ${DTB_ADDR}"
