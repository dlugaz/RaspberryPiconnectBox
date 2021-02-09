#!/bin/bash
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

wget https://www.softether-download.com/files/softether/v4.34-9745-rtm-2020.04.05-tree/Linux/SoftEther_VPN_Server/32bit_-_ARM_EABI/softether-vpnserver-v4.34-9745-rtm-2020.04.05-linux-arm_eabi-32bit.tar.gz
ls
tar -xf softether-vpnserver-v4.34-9745-rtm-2020.04.05-linux-arm_eabi-32bit.tar.gz
ls
cd vpnserver/
ls
sudo make
cd ..
mv vpnserver/ /usr/local/
sudo mv vpnserver/ /usr/local/
cd /usr/local/vpnserver/
ls
sudo chmod +x vpncmd vpnserver

touch /etc/init.d/vpnserver
chmod +x /etc/init.d/vpnserver
cat > /etc/init.d/vpnserver << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides: softether-vpnserver
# Required-Start: $network $remote_fs $syslog
# Required-Stop: $network $remote_fs $syslog
# Should-Start: network-manager
# Should-Stop: network-manager
# X-Start-Before: $x-display-manager gdm kdm xdm wdm ldm sdm nodm
# X-Interactive: true
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: SoftEther VPN service
### END INIT INFO

# chkconfig: 2345 99 01
# description: SoftEther VPN Server
DAEMON=/usr/local/vpnserver/vpnserver
LOCK=/var/lock/vpnserver
test -x $DAEMON || exit 0
case "$1" in
start)
$DAEMON start
touch $LOCK
;;
stop)
$DAEMON stop
rm $LOCK
;;
restart)
$DAEMON stop
sleep 3
$DAEMON start
;;
*)
echo "Usage: $0 {start|stop|restart}"
exit 1
esac
exit 0
EOF

sudo update-rc.d vpnserver defaults
sudo /usr/local/vpnserver/vpncmd localhost /cmd ServerPasswordSet
sudo /usr/local/vpnserver/vpncmd localhost /cmd HubCreate VPN
sudo /usr/local/vpnserver/vpncmd localhost /cmd BridgeCreate VPN /DEVICE:eth0

cd ~
wget https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_armhf.deb
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

read "Everything done. Rebooting in 5s..." -t 5

sudo reboot

connectToZerotier()
{
	read -p "Input network ID " -r
	sudo zerotier-cli join $REPLY
	echo "Now, you have to confirm this peer's access on my.zerotier.com"
	sudo zerotier-cli info
}

connectToHamachi()
{
	read -p "Input network ID " -r
	sudo hamachi login
	sudo hamachi join $REPLY
	echo hamachi
}

checkConnection()
{
	wget -q --spider http://google.com
	if [ $? -eq 0 ]; then
		return 1;
	else
		return 0;
	fi
}