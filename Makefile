NETWORK ?= baremetal
METALLB_DIR = /opt/openshift-network-playground/libvirt/metallb
METALLB_CLOUDINIT_USER ?= ./metallb-metallb/fedora-user-data.yaml
METALLB_CLOUDINIT_NETWORK ?= ./metallb-metallb/fedora-network-dhcp-v1.yaml
METALLB_IMAGE ?= https://download.fedoraproject.org/pub/fedora/linux/releases/38/Cloud/x86_64/images/Fedora-Cloud-Base-38-1.6.x86_64.qcow2

.PHONY: help

help:
	@echo "AVAILABLE TARGETS"
	@awk '/^.PHONY:/ {print $$2}' ${PWD}/Makefile

check-metallb-ip:
ifndef METALLB_IP
	$(error METALLB_IP is undefined)
endif

.PHONY: metallb

metallb:
	@./vm.sh ${NETWORK} ${METALLB_DIR} ${METALLB_CLOUDINIT_USER} ${METALLB_CLOUDINIT_NETWORK} ${METALLB_IMAGE}

.PHONY: resize-disk

resize-disk:
	@sudo virsh destroy metallb || true && sudo qemu-img resize ${METALLB_DIR}/metallb.qcow2 10G

.PHONY: ssh-dnat

ssh-dnat: check-metallb-ip
	@sudo iptables-save | grep '\--dport 2222' && sudo iptables -t nat $$(sudo iptables-save | grep '\--dport 2222' | sed 's/^-A/-D/') || true
	@sudo /usr/sbin/iptables -t nat -I PREROUTING -p tcp -i $$(/usr/sbin/ip route show default | awk '{print $$5}') --dport 2222 -j DNAT --to-destination ${METALLB_IP}:22

.PHONY: edit-ssh

edit-ssh: check-metallb-ip
	@ssh onp@${METALLB_IP} 'bash -s' < metallb-metallb/gpg.sh
