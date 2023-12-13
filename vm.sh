#!/bin/bash
# The script needs userdata, networkdata, network and directory as an args

set -eou pipefail

BRIDGE=${1}
NETWORK=$(echo ${BRIDGE} | tr "," "\n" | while read bridge; do echo --network bridge=${bridge}; done)
DIRECTORY=${2}
CLOUDINIT_USER_DATA=${3}
CLOUDINIT_NETWORK_CONFIG=${4}
IMAGE=${5}
HOST_IP=$(ip r s default | awk '{print $9}')
ONP_DIR=/home/onp/openshift-network-playground

VM_NAME=$(basename -- ${DIRECTORY})
VM_NAME=${VM_NAME%.*}
IMAGE_NAME=$(basename -- ${IMAGE})
EXTENSION=${IMAGE_NAME##*.}
DISK=${DIRECTORY}/${VM_NAME}.${EXTENSION}
DOWNLOAD=$(dirname ${DIRECTORY})/${VM_NAME}.${EXTENSION}
REMOTE_IMAGE_SIZE=$(curl -s -L -I ${IMAGE} | awk -v IGNORECASE=1 '/^Content-Length/ { print $2 }')
LOCAL_IMAGE_SIZE=$(du -b ${DOWNLOAD} | awk '{print $1}' 2>/dev/null || echo "")

sudo rm -rf ${DIRECTORY}
sudo mkdir -p ${DIRECTORY}
sudo cloud-localds -m local --network-config=${CLOUDINIT_NETWORK_CONFIG} ${DIRECTORY}/seed.iso ${CLOUDINIT_USER_DATA}
if [[ ${REMOTE_IMAGE_SIZE%$'\r'} != ${LOCAL_IMAGE_SIZE} ]]; then
        echo "Downloading ${VM_NAME} image ..."
        sudo curl -#Lo ${DOWNLOAD} ${IMAGE}
fi
sudo cp ${DOWNLOAD} ${DISK}

sudo virsh -q destroy ${VM_NAME} > /dev/null || true
sudo virsh -q undefine ${VM_NAME} > /dev/null || true
sudo virt-install --name ${VM_NAME} \
                  --vcpus 1 \
                  --ram 2048 \
                  --os-variant fedora-unknown \
                  --import \
                  ${NETWORK} \
                  --disk ${DISK} \
                  --disk ${DIRECTORY}/seed.iso \
                  --graphics spice,listen=${HOST_IP} \
                  --video virtio \
                  --channel spicevmc \
                  --console pty,target.type=virtio \
                  --serial pty \
                  --noautoconsole
sudo virsh console ${VM_NAME}
