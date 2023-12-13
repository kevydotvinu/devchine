# Devchine
This creates a standalone virtual machine for the development.

## Prerequisites
### Install packages
```
sudo yum install cloud-utils
```
### Create bridge interface
```
sudo ip link add name baremetal type bridge
sudo ip link set dev baremetal up
sudo ip link add bridge-dummy type dummy
sudo ip link set dev bridge-dummy master baremetal
sudo ip addr add 192.168.123.1/24 dev baremetal
```

## MetalLB
```
make metallb
ssh onp@<vm> (password: Onp@123)
tail -f /var/log/cloud-init.log
sudo virsh destroy metallb
sudo qemu-img resize /opt/openshift-network-playground/libvirt/metallb/metallb.qcow2 +10G
sudo virsh start metallb
ssh onp@<vm> (password: Onp@123)
cd metallb-metallb
inv dev-env
```
