######################################### QEMU script for WINDOWS GUEST ###################################################################

# To use the host cdrom use -cdrom /dev/sr0
# to add virtual usb create a qcow2 hd then add the following
#  -drive if=none,id=stick,file=/home/usb.qcow2  -device nec-usb-xhci,id=xhci  -device usb-storage,bus=xhci.0,drive=stick 
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
# qemu-nbd --connect /dev/nbd0 /home/usb.qcow2
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
# install all the virtio drivers, spice guest agent qemu guest agent, winFSP and USBdk utility in the guest for 
# better performance. This script enables clipboard sharing,shared folders between host and host and usb passthrough.
# match the value of hostbus and hostaddr to that of the usb port which the usb device uses.
# To use OpenGL in windows guest use -device virtio-vga-gl -display gtk,gl=on but it would be slow and it 
# seems virglrenderer can't be used in windows guest.


#! /bin/bash

qemu-system-x86_64 \
	-enable-kvm \
	-machine type=q35,accel=kvm \
	-m 4.5G \
	-cpu max \
	-device intel-hda -device hda-duplex \
	-drive file=/home/in.qcow2,format=qcow2,media=disk,if=virtio \
	-usb -usbdevice mouse -usbdevice keyboard \
	-device virtio-vga \
	-display gtk \
	-net nic \
	-net user,smb=/home/wgit \
	-drive file=/home/usb.qcow2,format=qcow2,media=disk,if=virtio \
	-drive file=/home/usb2.qcow2,format=qcow2,media=disk,if=virtio \
	-boot order=d -drive file='/home/cd.ISO',format=raw,media=cdrom \
	-drive file=/home/vir.iso,format=raw,media=cdrom \
	-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on \
    	-device virtio-serial-pci \
    	-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0 \
	-usb -device usb-host,hostbus=1,hostaddr=44
