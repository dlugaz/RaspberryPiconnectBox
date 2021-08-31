#!/bin/bash

connectToZerotier ()
{
	read -p "Input network ID " -r
	sudo zerotier-cli join $REPLY
	echo "Now, you have to confirm this peer's access on my.zerotier.com"
	sudo zerotier-cli info
}

connectToHamachi ()
{
	read -p "Input network ID " -r
	sudo hamachi login
	sudo hamachi join $REPLY
	echo hamachi
}

checkConnection ()
{
	wget -q --spider http://google.com
	if [ $? -eq 0 ]; then
		return 1;
	else
		return 0;
	fi
}

setupVPNServer ()
{

	cd ~
	wget https://github.com/dlugaz/RaspberryPiconnectBox/raw/master/InstalationFiles/softether-vpnserver-v4.34-9745-rtm-2020.04.05-linux-arm_eabi-32bit.tar.gz
	wget https://raw.githubusercontent.com/dlugaz/RaspberryPiconnectBox/master/vpnserver;

	tar -xf softether-vpnserver-v4.34-9745-rtm-2020.04.05-linux-arm_eabi-32bit.tar.gz

	cd vpnserver/
	sudo make
	cd ..
	rm -rf /usr/local/vpnserver
	mv vpnserver/ /usr/local/
	sudo mv vpnserver/ /usr/local/
	cd /usr/local/vpnserver/

	sudo chmod +x vpncmd vpnserver

	sudo mv ~/vpnserver /etc/init.d/
	chmod +x /etc/init.d/vpnserver

	sudo update-rc.d vpnserver defaults
	sudo /usr/local/vpnserver/vpncmd localhost /cmd ServerPasswordSet
	sudo /usr/local/vpnserver/vpncmd localhost /cmd HubCreate VPN
	sudo /usr/local/vpnserver/vpncmd localhost /cmd BridgeCreate VPN /DEVICE:eth0
	
}

echo rPI ConnectionBOX installation script!
echo ##########################################################################
checkConnection
if [ $? -eq 0 ]; then
		echo "This script requires internet connection!"
		exit
fi
echo Setup Password for this device
passwd
sudo rfkill unblock 0
sudo apt update
sudo apt -y upgrade
sudo apt install comitup
sudo rm /etc/wpa_supplicant/wpa_supplicant.conf
sudo systemctl disable systemd-resolved
echo "ap_name: connectionBox-<nn>" > comitup.conf
sudo mv comitup.conf /etc/

setupVPNserver

cd ~
wget https://github.com/dlugaz/RaspberryPiconnectBox/raw/master/InstalationFiles/logmein-hamachi_2.1.0.203-1_armhf.deb
sudo apt install ./logmein-hamachi_2.1.0.203-1_armhf.deb
curl -s https://install.zerotier.com | sudo bash


while true; do
    read -p "Would you like to connect to zerotier network?" yn
    case $yn in
        [Yy]* ) connectToZerotier; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    read -p "Would you like to connect to hamachi network?" yn
    case $yn in
        [Yy]* ) connectToHamachi; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

sudo hostname connectionBox

read -t 5 -p "Everything done. Rebooting in 5s..."

sudo reboot

