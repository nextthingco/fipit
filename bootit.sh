#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#------

BR2_PATH="$HOME/Projects/buildroot_openlinux/output/mesongxl_p230/images/"

#SPL_FILE=${1:-$BR2_PATH/u-boot.bin.usb.bl2}
SPL_FILE=${1:-$HOME/Projects/u-boot/output/u-boot.bin.usb.bl2}
#SPL_FILE="${SCRIPT_DIR}/default/u-boot.bin.usb.bl2"
#TPL_FILE=${2:-$BR2_PATH/u-boot.bin.usb.tpl}
TPL_FILE=${2:-$HOME/Projects/u-boot/output/u-boot.bin.usb.tpl}
#TPL_FILE="${SCRIPT_DIR}/default/u-boot.bin.usb.tpl"

UBOOTIMG=${2:-$HOME/Projects/u-boot/output/u-boot.bin.sd.bin}

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

! [[ -f "$KERNEL" ]] && echo "ERROR: $KERNEL not found" && exit 1
! [[ -f "$INITRD" ]] && echo "ERROR: $INITRD not found" && exit 1
! [[ -f "$DTB" ]] && echo "ERROR: $DTB not found" && exit 1
! [[ -f "$UBOOTIMG" ]] && echo "ERROR: $DTB not found" && exit 1

echo "using SPL_FILE=${SPL_FILE}"
echo "using TPL_FILE=${TPL_FILE}"

${SCRIPT_DIR}/update identify 

#${SCRIPT_DIR}/update wreg 0x1b8ec003 0xc88345c8
#echo "Press ENTER to continue"
#read

echo "-- DDR init --"
${SCRIPT_DIR}/update cwr "${SPL_FILE}" $SPL_ADDR
${SCRIPT_DIR}/update write "${PARA_DDRINIT}" $PARA_ADDR
${SCRIPT_DIR}/update run $SPL_ADDR

sleep 1

echo "-- run uboot --"
echo "uploading u-boot img ${UBOOTIMG} to address ${UBOOTIMG_ADDR}"
${SCRIPT_DIR}/update write "${UBOOTIMG}" "${UBOOTIMG_ADDR}" && \
#echo "uploading kernel ${KERNEL} to address ${KERNEL_ADDR}"
#${SCRIPT_DIR}/update write "${KERNEL}" "${KERNEL_ADDR}" && \
#echo uploading initrd
#${SCRIPT_DIR}/update write "${INITRD}" "${INITRD_ADDR}" && \
#echo uploading dtb
#${SCRIPT_DIR}/update write "${DTB}" "${DTB_ADDR}" && \

echo uploading spl
${SCRIPT_DIR}/update write "${SPL_FILE}" $SPL_ADDR && \
echo uploading tpl
${SCRIPT_DIR}/update write "${TPL_FILE}" $TPL_ADDR && \
echo uploading para
${SCRIPT_DIR}/update write "${PARA_RUNFIPIMG}" $PARA_ADDR && \
echo boot!
${SCRIPT_DIR}/update run $SPL_ADDR

sleep 3
#${SCRIPT_DIR}/update bulkcmd "setenv bootargs rootfstype=ramfs init=/init console=ttyS0,115200 no_console_suspend earlyprintk=aml-uart,0xc81004c0 ramoops.pstore_en=1 ramoops.record_size=0x8000 ramoops.console_size=0x4000 androidboot.selinux=enforcing logo=osd1,loaded,0x3d800000,576cvbs maxcpus=4 vout=576cvbs,enable hdmimode=1080p60hz cvbsmode=576cvbs hdmitx= cvbsdrv=0 pq= androidboot.firstboot=1 jtag=apao androidboot.hardware=amlogic androidboot.slot_suffix=_a"

#${SCRIPT_DIR}/update bulkcmd "run storeargs"
${SCRIPT_DIR}/update bulkcmd "booti ${KERNEL_ADDR} ${INITRD_ADDR} ${DTB_ADDR}"
