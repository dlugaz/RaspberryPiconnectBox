# ConnectionBox with RaspberryPi

## What is it: 
This is a project to turn rPi into VPN bridge that would work everywhere, no matter the connection, firewall etc. At the same time it should use free software and not generate any costs for the user. This project started mainly to provide a reliable, cheap access to remote PLCs. To accomplish this, there is a redundancy in VPN connections.

-   **Softether** - free vpn software, that's easy to use and creates totally transparent bridge VPN connection. This is the main workhorse. It's disadvantage is that it cannot connect through routers and firewalls.
-   **Zerotier** - free vpn software. It allows to jump through firewalls etc.
-   **Hamachi** - similar to zerotier, just less free.

So this is just a convenience script to facilitate setting up already available tools. 
## Requirements:
You need to install **Softether VPN client** and **Hamachi Client** and/or **Zerotier Client** on your PC
## How to use: 
 If rPi has a connection, that has direct line to internet and it's own IP - great, all you need is Softether. Softether automatically generates dynamicdns address and azure gateway address. Additional disadvantage is that connection is totally transparent, so there's no way to change rPi settings or diagnose connection. Dynamic DNS allows you to connect if rPI has direct internet connection, but no static ip. Azure DNS allows you to connect if there's no direct connection, but is slow as hell, so we can use it only in emergency. The DDNS and Azure DNS addresses are available if you connect to rPI with Softether Server Manager. 
To overcome the softether disadvantages there's a redundant connection through Hamachi and Zerotier. 
Additionally, to facilitate using local WiFi networks, comitup is installed. If it doesn't find any known network, it creates accesspoint (SSID: connectionBox-XX). When connected to this AP, on [http://10.42.0.1](http://10.42.0.1) you will find website, that allows to easily connect to picked network.

### So, if everything is configured the usage is as follows:

1.  Connect rPI with ethernet cable to destination network
2.  Use usb LTE modem, or use **comitup** to connect rPi to WiFi network
3.  Connect your PC to hamachi/zerotier network
4.  Connect your PC to VPN with **Softether Client Manager**. Use either DDNS address, hamachi/zerotier IP, azure address, or hostname (rPIConnectionBox).
5.  If you use virtual machine to connect to PLC, then bridge virtual machine network with softether vpn network.

## Installation and configuration: 

### Option 1 - ready image:

1.  On a SD card etch **rpiVPN.gz** (for example with balenaEtcher)
2.  Put the SD card into RaspberryPi.

### Option 2 - installation script:

1.  Etch pure RASPBIAN on rPi and initialize system, connect to internet.
    
2.  Execute in terminal
	>  wget https://raw.githubusercontent.com/dlugaz/RaspberryPiconnectBox/master/connectionBox.sh; chmod +x ./connectionBox.sh; ./connectionBox.sh
    
4.  Turn on Raspberry. A new WiFi network should appear - connectionBox-XX.
    
5.  Connect to rPi via WiFi or Ethernet.
    
6.  Use Softether configuration tool to configure VPN on rPi. Remember to setup a bridge with eth0 in the wizard!
    
7.  Connect with SSH to connect zerotier and/or hamachi
Hi! I'm your first Markdown file in **StackEdit**. If you want to learn about StackEdit, you can read me. If you want to play with Markdown, you can edit me. Once you have finished with me, you can create new files by opening the **file explorer** on the left corner of the navigation bar.

