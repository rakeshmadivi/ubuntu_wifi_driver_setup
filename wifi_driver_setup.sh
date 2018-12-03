function help()
{
	echo -e "Online Sources:\n"
	echo -e "https://help.ubuntu.com/community/WifiDocs/Driver/bcm43xx"
	printf "Download Location:\n https://wireless.wiki.kernel.org/en/users/Drivers/b43/developers"
	printf "b43 Tools:\n https://github.com/mbuesch/b43-tools"
	printf "Open source Driver Details:\n Broadcom brcmsmac(PCIe) and brcmfmac(SDIO/USB) drivers: \nhttps://wireless.wiki.kernel.org/en/users/Drivers/brcm80211"
}

function download_help()
{
	printf "------------- NOTES -------------------------"
	printf "Download Firware Cutter & Firmware from:\n"
	printf "http://www.lwfinger.com/b43-firmware/"
	printf "https://launchpad.net/ubuntu/+source/b43-fwcutter"
	printf "Specific(used in laptop): \nhttp://www.lwfinger.com/b43-firmware/broadcom-wl-6.30.163.46.tar.bz2 \nhttps://launchpad.net/ubuntu/+archive/primary/+files/b43-fwcutter_019-2_i386.deb"
	
	printf "---------------------------------------------"
}

function install_firmware_cutter()
{
	printf "Installing b43-fwcutter_019-2...\n"
	sudo dpkg -i b43-fwcutter_019-2_amd64.deb	#i386.deb	#b43-fwcutter* 
}

function install_offline_wifi_bcmwl()
{
	printf "Installing bcmwl-kernel-source driver....\n"
	sudo dpkg --install bcmwl-kernel-source_6.30.223.271+bdcom-0ubuntu1_1.3_amd64.deb
}

function install_offline_wifi_broadcom()
{
	printf "Installing using OFFLINE Method...\n"
	# Firmware Extraction
	if [ ! -d "$PWD/broadcom-wl-6.30.163.46" ]
	then
		printf "Extracting opensource broadcom-wl-6.30.163.46...."
		tar xfvj broadcom-wl-6.30.163.46.tar.bz2	#broadcom-wl-5.100.138.tar.bz2
	fi

	# Firmware Installation
	printf "Extract and install the Broadcom Firmware/Driver using b43-fwcutter...\n"
	sudo b43-fwcutter -w /lib/firmware broadcom-wl-6.30.163.46.wl_apsta.o	#broadcom-wl-5.100.138/linux/wl_apsta.o

	# Load the Driver
	sudo modprobe b43

	# Update initramfs if blacklist is updated in /etc/modprobe.d/ folder
	#sudo update-initramfs -u
	
	: '
		Note: The bcmwl-kernel-source package will automatically blacklist the open source drivers/modules in /etc/modprobe.d/blacklist-bcm43.conf.

		If you wish to permanently use the open source drivers then remove the bcmwl-kernel-source package:
	'
	printf "Purging bcmwl-kernel-source...\n"
	sudo apt-get purge bcmwl-kernel-source

	printf "Now REBOOT the system.\n"
}

printf "List the wireless devices status(y/n)? "
read list
if [ $list = "y" ]
then
	rfkill list all
fi 

printf "Correct wireless issues using online(y/n)? "
read online

if [ $online = "y" ]
then
	# ONLINE INSTALLATION
	printf "Using ONLINE Installation...\n"
	#sudo apt-get remove bcmwl-kernel-source
	
	# TEST DRIVER
	sudo modprobe -r b43 ssb wl brcmfmac brcmsmac bcma
	sudo modprobe wl

	# sudo apt-get remove --purge bcmwl-kernel-source
	# sudo apt-get install firmware-b43-installer b43-fwcutter

	# For OFFLINE Download from: bcmwl-kernel-source_6.30.223.271+bdcom-0ubuntu1~1.3_amd64.deb
	# [SOLVED]
	sudo apt-get install --reinstall bcmwl-kernel-source

else
	# Print Download links
	download_help

	# OFFLINE INSTALLATION
	printf "Using OFFLINE Installation...\n"
	: '
	Firmware installation
	Copy brcm/bcm43xx-0.fw and brcm/bcm43xx_hdr-0.fw to /lib/firmware/brcm (or wherever firmware is normally installed on your system)
	'
	
	# Firware Cutter installation
	#install_firmware_cutter()
	
	# INSTALL OFFLINE bcmwl-kernel-source WIFI DRIVER
	install_offline_wifi_bcmwl
fi
