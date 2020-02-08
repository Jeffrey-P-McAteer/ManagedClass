
# ManagedClass

ManagedClass is a standalone OS deployment suitable for teaching
approx. 32 children how to write code.

It makes the following resource assumptions:

 - Instructor has access to 1x PC with:
   - approx. 8-16GB ram. 8gb may be functional but you'll thrash your hard drive a lot with a full class.
   - 4 cores somewhere near 2ghz. Cell phones from 2014 outstrip this so don't spend time picking a CPU, they're all fine.
   - 80gb hdd space, ideally an SSD (because you'll be thrashing the hard drive with a full class, remember.)
   - Wireless dongle. This can be replaced with a wireless router, but this setup combines the two (server + router) into just a server so you don't have to cable it up, plus this makes the entire unit more portable.
   - Access to a power socket. I know of schools which disallow this, so be sure to check with your supervisor before using electricity.

 - Students have access to a PC with:
   - RDP client OR web browser
   - Configurable wireless card OR ethernet



## Beginning

To start with you'll need a USB drive (2gb will do) and a computer capable of writing a binary file to a USB drive.

I will be using Arch Linux because that's what cool programmers use, but each of the steps
will have enough instructions you should be able to google around to replace eg `dd` with the equivelant
operation on your OS. As always, contact your OS support if they forgot to give you a user manual or if you lost your copy of the user manual. (The Arch user manual is at https://wiki.archlinux.org/index.php/)

## Server Management

I did not sit down with a keyboard + monitor, I used `ipmiview` to setup
my server. As a note to anyone else doing this, the default IP is 192.168.1.99 for SuperMicro servers.

To quickly put your ethernet port in the right place:

```bash
sudo ip link set enp4s0 up
sudo ip a add 192.168.1.11/24 dev enp4s0
ping -c 1 192.168.1.99 # should return something
```

## Create Install Media

We'll be deploying Arch Linux on the server. Any OS will do,
good picks are CentOS and Fedora, followed by SuSe, then Debian,
and finally Ubuntu is _technically_ an operating system.

Actually, to save on setup headache we'll be using Manjaro which
is an extension of Arch with a nice GUI.

```bash
# Download this: https://manjaro.org/download/official/architect/
# Remember to replace /dev/sda with your USB drive!
sudo dd if=/path/to/manjaro-architect-18.1.0-stable-x86_64.iso of=/dev/sda status=progress oflag=sync
```

## Boot install media on server

There isn't a command for this one, you actually hafta get out of your chair
and plug the disk in then hit the power button. I'm disappointed as well,
`ipmiview` needs to get a remote USB extension.

## Install Arch Linux

Arch is "linux with a nice package manager". You
can set it up a bazillion ways, so I'm going to link
to the thing I followed and then drop decisions I made
specific to ManagedClass here: https://wiki.archlinux.org/index.php/installation_guide




## Cockpit

## RDP Server

## Apache Guacamole Server

There is a concern that students may not have access to an RDP client.

At a performance cost we will add an Apache Guacamole server which
may be accessed via a web browser.



## NginX Server

## Samba 

## DHCP Server







