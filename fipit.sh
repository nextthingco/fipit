#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
UBOOT_BIN="${1:-$PWD/u-boot.bin}"

TMP_DIR="${PWD}/tmp"
mkdir -p "${TMP_DIR}"

OUTPUT_DIR="${2:-$PWD/output}"
mkdir -p "${OUTPUT_DIR}"

OUTPUT_UBOOT_BIN="${OUTPUT_DIR}/$(basename "${UBOOT_BIN}")"

BL2_NEW_BIN="${SCRIPT_DIR}/bl2_new.bin"
BL30_NEW_BIN="${SCRIPT_DIR}/bl30_new.bin"
BL31_IMG="${SCRIPT_DIR}/bl31.img"
BL33_BIN="${SCRIPT_DIR}/bl31.img"

FIP_BIN="${TMP_DIR}/fip.bin"
BOOT_NEW_BIN="${TMP_DIR}/boot_new.bin"

BL2_NEW_BIN_SIG="${TMP_DIR}/bl2_new.bin.sig"
BL30_NEW_BIN_ENC="${TMP_DIR}/bl30_new.bin.enc"
BL31_IMG_ENC="${TMP_DIR}/bl31.img.enc"
UBOOT_BIN_ENC="${TMP_DIR}/$(basename "${UBOOT_BIN}").enc"


echo "fipin' '$UBOOT_BIN'..."

rm -f "${FIP_BIN}"
${SCRIPT_DIR}/fip_create --bl30 "${BL30_NEW_BIN}" --bl31 "${BL31_IMG}" --bl33 "${UBOOT_BIN}" "${FIP_BIN}"
${SCRIPT_DIR}/fip_create --dump "${FIP_BIN}"

cat "${BL2_NEW_BIN}" "${FIP_BIN}" >"${BOOT_NEW_BIN}"

${SCRIPT_DIR}/aml_encrypt_gxl --bl3enc --input "${BL30_NEW_BIN}" --output "${BL30_NEW_BIN_ENC}"
${SCRIPT_DIR}/aml_encrypt_gxl --bl3enc --input "${BL31_IMG}" --output "${BL31_IMG_ENC}"
${SCRIPT_DIR}/aml_encrypt_gxl --bl3enc --input "${UBOOT_BIN}" --compress lz4 --output "${UBOOT_BIN_ENC}"
${SCRIPT_DIR}/aml_encrypt_gxl --bl2sig --input "${BL2_NEW_BIN}" --output "${BL2_NEW_BIN_SIG}"

${SCRIPT_DIR}/aml_encrypt_gxl --bootmk --output ${OUTPUT_UBOOT_BIN} \
  --bl2   "${BL2_NEW_BIN_SIG}" \
  --bl30  "${BL30_NEW_BIN_ENC}"  \
  --bl31  "${BL31_IMG_ENC}" \
  --bl33  "${UBOOT_BIN_ENC}"


