#!/bin/bash -eu

NIXOS_IMAGE=""
FOG_GHAF_GIT_REVISION=""
FOG_GHAF_TAG=""
HW_TARGET="salukiv3"  # Default hardware target
LOOP_DEVICE=""
TMP_IMAGE="sd-image.img"
BOOT_IMAGE="boot.img"
ROOT_IMAGE="root.img"
BOOT_IMAGE_ZSTD="${BOOT_IMAGE}.zst"
ROOT_IMAGE_ZSTD="${ROOT_IMAGE}.zst"
FOG_HYPER_IMAGES_DIR="/var/lib/foghyper/image"
FORCE_ORAS_PUSH=false
FORCE_MOVE_IMAGES_TO_LOCAL_DIR=false
FORCE_COMPRESS_IMAGES=false

while getopts "h?i:r:t:s:olz" opt; do
    case "$opt" in
    h|\?)
        echo "Usage: $0 -i nixos-image [-r fog-ghaf-git-rev] [-t tag] [-s hw-target] [-l] [-o] [-z]"
        echo "-i nixos-image: input image from fog-ghaf builds"
        echo "-r fog-ghaf-git-rev: hash of the git revision of the image to be pushed"
        echo "-t tag: tag that will be appended to the sha-xxxxxxx tag, for example it can be the branch name"
        echo "-s hw-target: hardware target (salukiv3, salukiv3s), default: salukiv3"
        echo "-l: automatically move images to local images directory (${FOG_HYPER_IMAGES_DIR})"
        echo "-o: automatically push images to the registry (oras push)"
        echo "-z: compress images with zstd tool"
        exit 0
        ;;
    i)  NIXOS_IMAGE=$OPTARG
        ;;

    r)  FOG_GHAF_GIT_REVISION=$OPTARG
        ;;

    t)  FOG_GHAF_TAG=$OPTARG
        ;;

    s)  HW_TARGET=$OPTARG
        ;;

    o)  FORCE_ORAS_PUSH=true
        ;;

    l)  FORCE_MOVE_IMAGES_TO_LOCAL_DIR=true
        ;;

    z)  FORCE_COMPRESS_IMAGES=true
        ;;
    esac
done

function confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [Y/n]} " response
    case "$response" in
        [nN][oO]|[nN])
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

function clean_up() {
    echo "INFO: Perform clean up."

    TMP_DEV=$(losetup | grep sd-image | awk '{print $1}')
    if [ "${TMP_DEV}" == "${LOOP_DEVICE}" ] ; then
        echo "INFO: detach loop device ${LOOP_DEVICE}."
        sudo losetup --detach "${LOOP_DEVICE}"
    fi

    if [ -e "${TMP_IMAGE}" ]; then echo "INFO: remove temporary image (${TMP_IMAGE})."; rm -rf "${TMP_IMAGE}" ; fi

    if [ -e "${BOOT_IMAGE}" ]; then echo "INFO: remove boot image (${BOOT_IMAGE})."; rm -rf "${BOOT_IMAGE}" ; fi

    if [ -e "${ROOT_IMAGE}" ]; then echo "INFO: remove root image (${ROOT_IMAGE})."; rm -rf "${ROOT_IMAGE}" ; fi

    if [ -e "${BOOT_IMAGE_ZSTD}" ]; then echo "INFO: remove boot image (${BOOT_IMAGE_ZSTD})."; rm -rf "${BOOT_IMAGE_ZSTD}" ; fi

    if [ -e "${ROOT_IMAGE_ZSTD}" ]; then echo "INFO: remove root image (${ROOT_IMAGE_ZSTD})."; rm -rf "${ROOT_IMAGE_ZSTD}" ; fi
}
trap 'clean_up' ERR

if [ -z ${NIXOS_IMAGE} ] || [ "${NIXOS_IMAGE}" == "" ]; then echo "ERROR: Image parameter is mandatory"; exit 1; fi

if [ ! -e "${NIXOS_IMAGE}" ]; then echo "ERROR: File image ${NIXOS_IMAGE} does not exist"; exit 1; fi

# Validate hardware target
case "${HW_TARGET}" in
    salukiv3|salukiv3s|salukiv3x)
        echo "INFO: Using hardware target: ${HW_TARGET}"
        ;;
    *)
        echo "ERROR: Invalid hardware target '${HW_TARGET}'. Valid options: salukiv3, salukiv3s, salukiv3x"
        exit 1
        ;;
esac

echo "INFO: Using image ${NIXOS_IMAGE}."
if ! confirm "Is this correct image? [Y/n]"; then echo "INFO: User stopped execution."; exit 1; fi
zstd -d -o "${TMP_IMAGE}" "${NIXOS_IMAGE}"

echo "INFO: sudo credentials are needed to mount a loop device."
if ! confirm "Do you want to continue? [Y/n]"; then echo "INFO: User stopped execution."; clean_up; exit 1; fi
sudo losetup --find --partscan "${TMP_IMAGE}"

LOOP_DEVICE=$(losetup | grep sd-image | awk '{print $1}')
if [ -z ${LOOP_DEVICE} ] || [ "${LOOP_DEVICE}" == "" ]; then echo "ERROR: Image mounted on loop device was not found."; clean_up; exit 1; fi
echo "INFO: image mounted on ${LOOP_DEVICE} loop device."

echo "INFO: extract boot image."
sudo dd if="${LOOP_DEVICE}p1" of="${BOOT_IMAGE}" bs=1M status=progress
BOOT_SHA256=$(sha256sum "${BOOT_IMAGE}" | awk '{print $1}')
echo "INFO: SHA256 of ${BOOT_IMAGE} is ${BOOT_SHA256}."

echo "INFO: extract root image."
sudo dd if="${LOOP_DEVICE}p2" of="${ROOT_IMAGE}" bs=1M status=progress
ROOT_SHA256=$(sha256sum "${ROOT_IMAGE}" | awk '{print $1}')
echo "INFO: SHA256 of ${ROOT_IMAGE} is ${ROOT_SHA256}."

if [ -z ${FOG_GHAF_GIT_REVISION} ] || [ "${FOG_GHAF_GIT_REVISION}" == "" ]; then
    echo "INFO: Git revision of fog-ghaf not given. Skipping oras push step."
else
    echo "INFO: The following step requires to have write access to the registry ghcr.io/tiiuae."
    if [ ${FORCE_ORAS_PUSH} == false ] && ! confirm "Do you want to push the root and boot images to the registry? [Y/n]"; then
        echo "INFO: Images not pushed to the registry."
    else
        if [ ${FORCE_COMPRESS_IMAGES} == true ] || confirm "Do you want to compress the root and boot images before pushing to the registry? [Y/n]"; then
            echo "INFO: Compressing images before pushing images to the registry."
            zstd "${BOOT_IMAGE}" -o "${BOOT_IMAGE_ZSTD}"
            zstd "${ROOT_IMAGE}" -o "${ROOT_IMAGE_ZSTD}"
            if [ ! -e "${BOOT_IMAGE_ZSTD}" ]; then echo "ERROR: ${BOOT_IMAGE_ZSTD} does not exist, exiting now."; clean_up; exit 1; fi
            if [ ! -e "${ROOT_IMAGE_ZSTD}" ]; then echo "ERROR: ${ROOT_IMAGE_ZSTD} does not exist, exiting now."; clean_up; exit 1; fi
            # The images pushed to the registry have always the same name although they are compressed.
            # We need to remove the original images and rename the compressed images.
            rm -f "${BOOT_IMAGE}" "${ROOT_IMAGE}"
            mv "${BOOT_IMAGE_ZSTD}" "${BOOT_IMAGE}"
            mv "${ROOT_IMAGE_ZSTD}" "${ROOT_IMAGE}"
        fi
        if [ ! -e "${BOOT_IMAGE}" ]; then echo "ERROR: ${BOOT_IMAGE} does not exist, exiting now."; clean_up; exit 1; fi
        if [ ! -e "${ROOT_IMAGE}" ]; then echo "ERROR: ${ROOT_IMAGE} does not exist, exiting now."; clean_up; exit 1; fi
        # Check if already logged in, if not ask for credentials
        if ! docker info >/dev/null 2>&1 || ! echo "test" | docker login ghcr.io --username test --password-stdin >/dev/null 2>&1; then
            echo "INFO: Authentication required for ghcr.io registry."
            read -p "Enter your GitHub username: " GITHUB_USERNAME
            read -s -p "Enter your GitHub Personal Access Token (PAT): " CR_PAT
            echo # New line after password input

            if [ -z "${GITHUB_USERNAME}" ] || [ -z "${CR_PAT}" ]; then
                echo "ERROR: Username and PAT are required for authentication."
                clean_up
                exit 1
            fi

            echo "INFO: Logging in to ghcr.io..."
            if ! echo "${CR_PAT}" | docker login ghcr.io -u "${GITHUB_USERNAME}" --password-stdin; then
                echo "ERROR: Failed to authenticate with ghcr.io. Please check your credentials."
                clean_up
                exit 1
            fi
            echo "INFO: Successfully logged in to ghcr.io."
        else
            echo "INFO: Already authenticated with Docker registry."
        fi
        echo "INFO: Pushing images to the registry."
        TAG=""
        if [ ! -z ${FOG_GHAF_TAG} ] && [ "${FOG_GHAF_TAG}" != "" ]; then
            TAG=",${FOG_GHAF_TAG}"
        fi
        # Determine registry repository based on hardware target
        case "${HW_TARGET}" in
            salukiv3)
                REGISTRY_REPO="ghcr.io/tiiuae/fog-ghaf"
                ;;
            salukiv3s)
                REGISTRY_REPO="ghcr.io/tiiuae/fog-ghaf-salukiv3s"
                ;;
            salukiv3x)
                REGISTRY_REPO="ghcr.io/tiiuae/fog-ghaf-salukiv3x"
                ;;
        esac
        # TAG variable maybe empty if not given by the user, which is fine.
        UPLOAD_COMMAND=$(echo "oras push ${REGISTRY_REPO}:sha-${FOG_GHAF_GIT_REVISION:0:7}${TAG}" \
            "boot.img:application/octet-stream" \
            "root.img:application/octet-stream" \
            --annotation "org.opencontainers.image.source=https://github.com/tiiuae/fog-ghaf" \
            --annotation "org.opencontainers.image.revision='${FOG_GHAF_GIT_REVISION}'" \
            --annotation "org.opencontainers.image.description='fog-ghaf partitions for ${HW_TARGET}'")

        echo "INFO: The following command will be executed:"
        echo "${UPLOAD_COMMAND}"
        if confirm "Do you want to excute the command? [Y/n]"; then
            eval ${UPLOAD_COMMAND}
        else
            echo "INFO: oras command was not executed but no worries, you can do it manually, just copy&paste the command and execute it."
        fi
    fi
fi

if [ ${FORCE_MOVE_IMAGES_TO_LOCAL_DIR} == false ] && ! confirm "Do you want to move the root and boot images to your local installation of fog-hyper (${FOG_HYPER_IMAGES_DIR})? [Y/n]"; then
    echo "INFO: Files not moved to your local installation."
else
    echo "INFO: Moving ${BOOT_IMAGE} to ${FOG_HYPER_IMAGES_DIR}/${BOOT_SHA256}."
    echo "mv ${BOOT_IMAGE} ${FOG_HYPER_IMAGES_DIR}/${BOOT_SHA256}"

    echo "INFO: Moving ${ROOT_IMAGE} to ${FOG_HYPER_IMAGES_DIR}/${ROOT_SHA256}."
    echo "mv ${ROOT_IMAGE} ${FOG_HYPER_IMAGES_DIR}/${ROOT_SHA256}"
fi

clean_up

exit 0
