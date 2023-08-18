# Devchine
This creates a standalone virtual machine for the development.

## MetalLB
```
make metallb
ssh onp@<vm> (password: Onp@123)
tail -f /var/log/cloud-init.log
sudo virsh destroy metallb
sudo qemu-img resize /opt/openshift-network-playground/libvirt/metallb/metallb.qcow2 +10G
sudo virsh start metallb
```
