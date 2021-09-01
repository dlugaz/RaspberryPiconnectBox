#!/bin/bash

connectToZerotier ()
{
	read -p "Input network ID " -r
	sudo zerotier-cli join $REPLY
	echo "##########################################################################"
	echo "Now, you have to confirm this peer's access on my.zerotier.com"
	echo "##########################################################################"
	sleep 5
	sudo zerotier-cli info
}

connectToHamachi ()
{
	read -p "Input network ID " -r
	sudo hamachi login
	sudo hamachi join $REPLY
	NEWHOSTNAME=$(hostname)
	sudo hamachi set-nick $NEWHOSTNAME
	echo hamachi
}

checkConnection ()
{
	wget -q --spider http://google.com
	if [ $? -eq 0 ]; then
		return 1;
	else
		echo "This script requires internet connection!"
		exit
	fi
}

setupVPNserver ()
{
	echo "##########################################################################"
	echo "Setting up Softether VPN Server"
	echo "##########################################################################"
	echo " "

	cd ~
	wget https://github.com/dlugaz/RaspberryPiconnectBox/raw/master/InstalationFiles/softether-vpnserver-v4.34-9745-rtm-2020.04.05-linux-arm_eabi-32bit.tar.gz
	

	tar -xf softether-vpnserver-v4.34-9745-rtm-2020.04.05-linux-arm_eabi-32bit.tar.gz

	cd vpnserver/
	make i_read_and_agree_the_license_agreement
	cd ~
	sudo rm -rf /usr/local/vpnserver
	sudo mv vpnserver/ /usr/local/
	cd /usr/local/vpnserver/
	sudo chmod +x vpncmd vpnserver
	
	cd ~
	wget https://raw.githubusercontent.com/dlugaz/RaspberryPiconnectBox/master/vpnserver;
	sudo mv ~/vpnserver /etc/init.d/
	sudo chmod +x /etc/init.d/vpnserver

	sudo update-rc.d vpnserver defaults
	
	sudo /usr/local/vpnserver/vpnserver start
	
	echo "##########################################################################"
	echo "Enter Password for VPN Server Management "
	read -s VPNPASSWORD
		
	sudo /usr/local/vpnserver/vpncmd localhost /SERVER /cmd ServerPasswordSet $VPNPASSWORD 
	sudo /usr/local/vpnserver/vpncmd localhost /SERVER /PASSWORD:$VPNPASSWORD /cmd HubCreate VPN /PASSWORD:$VPNPASSWORD
	sudo /usr/local/vpnserver/vpncmd localhost /SERVER /PASSWORD:$VPNPASSWORD /cmd BridgeCreate VPN /DEVICE:eth0
	sudo /usr/local/vpnserver/vpncmd localhost /SERVER /PASSWORD:$VPNPASSWORD /Hub:VPN /cmd UserCreate
	VPNPASSWORD=""
}

changeHostname ()
{
	read -p "What's your new hostname?" -r
	
	echo $REPLY > ~/hostname
	sudo mv ~/hostname /etc/	
}

checkSudo ()
{
	LOCALUSER=$(id -u)
	if [ $LOCALUSER -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi
}

setupComitUp ()
{
	echo "##########################################################################"
	echo "Setting up Comit Up"
	echo "##########################################################################"
	echo " "
	sudo apt install comitup
	sudo rm /etc/wpa_supplicant/wpa_supplicant.conf
	sudo systemctl disable systemd-resolved
	echo "ap_name: connectionBox-<nn>" > comitup.conf
	sudo mv comitup.conf /etc/
}

setupHamachi ()
{
	echo "##########################################################################"
	echo "Setting up Hamachi"
	echo "##########################################################################"
	echo " "
	cd ~
	wget https://github.com/dlugaz/RaspberryPiconnectBox/raw/master/InstalationFiles/logmein-hamachi_2.1.0.203-1_armhf.deb
	sudo apt install ./logmein-hamachi_2.1.0.203-1_armhf.deb
	
}

setupZerotier ()
{
	curl -s https://install.zerotier.com | sudo bash
}


#############################################################################
# Main
#############################################################################
echo "##########################################################################"
echo "rPI ConnectionBOX installation script!"
echo "##########################################################################"
echo " "

checkConnection

checkSudo

while true; do
	echo "##########################################################################"
	echo " "
    read -p "Would you like to change password (recommended) " yn
    case $yn in
        [Yy]* ) passwd pi; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

sudo rfkill unblock 0
sudo apt update
sudo apt -y upgrade

setupComitUp

setupVPNserver

setupZerotier

setupHamachi

while true; do
	echo "##########################################################################"
	echo " "
    read -p "Would you like to change hostname? " yn
    case $yn in
        [Yy]* ) changeHostname; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
    echo "##########################################################################"
    echo " "
    read -p "Would you like to connect to zerotier network? " yn
    case $yn in
        [Yy]* ) connectToZerotier; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

while true; do
	echo "##########################################################################"
	echo " "
    read -p "Would you like to connect to hamachi network? " yn
    case $yn in
        [Yy]* ) connectToHamachi; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done



echo "##########################################################################"
read -t 5 -p "Everything done. Rebooting in 5s..."

sudo reboot

