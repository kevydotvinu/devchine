NETWORK ?= baremetal
METALLB_DIR = /opt/openshift-network-playground/libvirt/metallb
METALLB_CLOUDINIT_USER ?= ./metallb-metallb/fedora-user-data.yaml
METALLB_CLOUDINIT_NETWORK ?= ./metallb-metallb/fedora-network-dhcp-v1.yaml
METALLB_IMAGE ?= https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2

check-metallb-ip:
ifndef METALLB_IP
        $(error METALLB_IP is undefined)
endif

.PHONY: help

help:
	@echo "AVAILABLE TARGETS"
	@awk '/^.PHONY:/ {print $$2}' ${PWD}/Makefile

.PHONY: metallb

metallb:
	@./vm.sh ${NETWORK} ${METALLB_DIR} ${METALLB_CLOUDINIT_USER} ${METALLB_CLOUDINIT_NETWORK} ${METALLB_IMAGE}

.PHONY: resize-disk

resize-disk:
	@qemu-img resize ${METALLB_DIR}/metallb.qcow2 10G

ssh-dnat: check-metallb-ip
	@iptables -t nat -I POSTROUTING --dport 2222 -j DNAT --to-destination ${METALLB_IP}:22
