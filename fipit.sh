#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
UBOOT_BIN="${1:-$PWD/u-boot.bin}"

TMP_DIR="${PWD}/tmp"
mkdir -p "${TMP_DIR}"

BL2_NEW_BIN="${SCRIPT_DIR}/bl2_new.bin"
BL30_NEW_BIN="${SCRIPT_DIR}/bl30_new.bin"
BL31_IMG="${SCRIPT_DIR}/bl31.img"
BL33_BIN="${SCRIPT_DIR}/bl31.img"

FIP_BIN="${TMP_DIR}/fip.bin}"
BOOT_NEW_BIN="${TMP_DIR}/boot_new.bin"
BL2_NEW_BIN_SIG="${TMP_DIR}/bl2_new.bin.sig"

echo "fipin' '$UBOOT_BIN'..."

rm -f "${FIP_BIN}"
${SCRIPT_DIR}/fip_create --bl30 "${BL30_NEW_BIN}" --bl31 "${BL31_IMG}" --bl33 "${UBOOT_BIN}" "${FIP_BIN}"
${SCRIPT_DIR}/fip_create --dump "${FIP_BIN}"

exit 
cat "${BL2_NEW_BIN}" "${FIP_BIN}" >"${BOOT_NEW_BIN}"

${SCRIPT_DIR}/aml_encrypt_gxl --bl3enc --input "${BL30_NEW_BIN}"
${SCRIPT_DIR}/aml_encrypt_gxl --bl3enc --input "${BL31_IMG}"
${SCRIPT_DIR}/aml_encrypt_gxl --bl3enc --input ${UBOOT_BIN} --compress lz4
${SCRIPT_DIR}/aml_encrypt_gxl --bl2sig --input "${BL2_NEW_BIN}" --output "${BL2_NEW_BIN_SIG}"

exit 
${SCRIPT_DIR}/aml_encrypt_gxl --bootmk --output output-u-boot.bin \
  --bl2   "${BL2_NEW_BIN_SIG}" \
  --bl30  ../fip/gxl/bl30_new.bin.enc  \
  --bl31  ../fip/gxl/bl31.img.enc \
  --bl33  ../fip/gxl/bl33.bin.enc


