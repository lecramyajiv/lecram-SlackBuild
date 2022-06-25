################### QEMU script for WIN XP ##################################

# To use the host cdrom use -cdrom /dev/sr0
# to add virtual usb create a qcow2 hd then add the following
#  -drive if=none,id=stick,file=/home/ben/qemu/usb.qcow2  -device nec-usb-xhci,id=xhci  -device usb-storage,bus=xhci.0,drive=stick 
# to change iso during install goto the compatmonitor in qemu and use the command info block  and eject the cdrom then use command
# change iso
# change ide1-cd0 /tmp/dsl-4.4.10.iso 
# info block
#  eject ide1-cd0
# command soundhw is depreceated use -device ac97  to find the list of supported devices
# use qemu-system-x86_64 -soundhw help 
# Here we add the -usb to add a host controller, and add -device usb-host,hostbus=2,hostaddr=3 to add the host's 
# USB device at Bus 2, Device 3. Simple as that.
# Ex: -usb -device usb-host,hostbus=2,hostaddr=3 
# To transfer files b/w host and guest use qemu-nbd it needs to be run as root or use sudo
# modprobe nbd max_part=8
# qemu-nbd --connect /dev/nbd0 /home/ben/virtual/usb.qcow2]
# get the partition no to mount with $fdisk /dev/nbd0 -l
# mount /dev/nbd0p1 /mnt
# to unmount umount /mnt
# qemu-nbd --disconnect /dev/nbd0 
# example for usb-passthrough -usb -device usb-host,hostbus=2,hostaddr=3 
# hostbus is bus no and host addr is the device no
# to enable clipboard sharing
# -chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on \
#  -device virtio-serial-pci \
#  -device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0
# to use shared folders use samba, when invoking qemu use -net user,smb=/folder and in the guest windows
# goto network in control panel and map the network drive and thats basically it and also enable network discovery
# For linux guest use virglrenderer to get near native performance.
# The hostbus and hostaddr changes everytime run lsusb before starting the VM.
# To use shared folders in linux guest make sure you have samba in linux guest then
# run mount -t cifs //10.0.2.4/qemu/ mount_point and to unmount run umount -a -t cifs -l


#! /bin/bash

qemu-system-x86_64 \
	-enable-kvm \
	-machine type=q35,accel=kvm \
	-m 4.5G \
	-cpu max \
	-device intel-hda -device hda-duplex \
	-drive file=/home/ben/virtual/slack.qcow2,format=qcow2,media=disk,if=virtio \
	-usb -usbdevice mouse -usbdevice keyboard \
	-device virtio-vga-gl \
	-display gtk,gl=on \
	-net nic \
	-net user,smb=/home/ben/wgit \
	-drive file=/home/ben/virtual/usb.qcow2,format=qcow2,media=disk,if=virtio \
	-drive file=/home/ben/virtual/usb2.qcow2,format=qcow2,media=disk,if=virtio \
	-boot order=d -drive file=/mnt/sys-e/iso/slackware64-15.0-install-dvd.iso,format=raw,media=cdrom \
	-drive file=/home/ben/Downloads/vir.iso,format=raw,media=cdrom \
	-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on \
	-device virtio-serial-pci \
   	-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0
