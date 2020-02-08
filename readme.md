
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

To start with you'll need a USB drive (4gb will do) and a computer capable of writing a binary file to a USB drive.

I will be using Arch Linux because that's what cool programmers use, but each of the steps
will have enough instructions you should be able to google around to replace eg `dd` with the equivelant
operation on your OS. As always, contact your OS support if they forgot to give you a user manual or if you lost your copy of the user manual. (The Arch user manual is at https://wiki.archlinux.org/index.php/)

## Create Install Media

We'll be deploying Arch Linux on the server. Any OS will do,
good picks are CentOS and Fedora, followed by SuSe, then Debian,
and finally Ubuntu is _technically_ an operating system.

Actually, to save on setup headache we'll be using Manjaro which
is an extension of Arch with a nice GUI.

```bash
# Download this: https://manjaro.org/download/community/i3/
# Remember to replace /dev/sda with your USB drive!
sudo dd if=/path/to/manjaro-i3-18.1.5-191229-linux54.iso of=/dev/sda status=progress oflag=sync
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

A manjaro-specific resource: https://forum.manjaro.org/t/installation-with-manjaro-architect-iso/20429

Essentially everything needs to be setup so at the end you have:

 - hard drive you can boot to
 - one non-root admin account (I called mine `admin`)
 - `yay`, `base-devel`, and LXDE (though these may be added after the initial install)

## Initial Package Updates

Arch is a rolling release system, so you will see lots of things
break (eg outdated signatures for developers) if your packages are old.

```bash
yay -Syu
```

Will make sure your system is up-to-date.

## LXDE

```bash
yay -S lxde
```

## RDP Server

```bash
yay -S xrdp xorgxrdp-git
sudo systemctl enable --now xrdp
sudo systemctl enable --now xrdp-sesman
```

Edit (creating if nonexistent) `/etc/X11/Xwrapper.config` and add `allowed_users=anybody`

Edit `/etc/X11/xinit/xinitrc` and make it launch LXDE: `exec startlxde`

If a user account does not launch LXDE, remove their `.xinitrc` file (or rename it to `.old.xinitrc`)

## Apache Guacamole Server

There is a concern that students may not have access to an RDP client.

At a performance cost we will add an Apache Guacamole server which
may be accessed via a web browser.

```bash
yay -S freerdp guacamole-server guacamole-client
sudo systemctl enable --now guacd
sudo systemctl enable --now tomcat8
```

Tomcat will run on `0.0.0.0:8080` and the guacamole client
is accessible at `http://your-ip:8080/guacamole/`

Guacamole uses a .xml file at `/usr/share/tomcat8/.guacamole/user-mapping.xml`
to authenticate users. To save ourselves from having to copy 30/60/90/120 usernames
and passwords we will build and install this plugin: https://github.com/voegelas/guacamole-auth-pam

```bash
wget https://github.com/voegelas/guacamole-auth-pam/releases/download/v1.4/guacamole-auth-pam-1.0.0.jar
sudo mkdir /usr/share/tomcat8/.guacamole/extensions
sudo cp guacamole-auth-pam-1.0.0.jar /usr/share/tomcat8/.guacamole/extensions
sudo vim /etc/pam.d/guacamole
sudo groupadd shadow
sudo chown root:shadow /etc/shadow
sudo chmod 660 /etc/shadow
sudo usermod -a -G shadow tomcat8
sudo vim /usr/share/tomcat8/.guacamole/unix-user-mapping.xml
```

`/etc/pam.d/guacamole` should contain:

```
#%PAM-1.0
auth      include  system-remote-login
account   include  system-remote-login
password  include  system-remote-login
session   include  system-remote-login

```

`unix-user-mapping.xml` should contain:

```
<?xml version="1.0" encoding="UTF-8"?>
<unix-user-mapping serviceName="guacamole">
    <config name="RDP Connection" protocol="rdp">
        <param name="hostname" value="localhost" />
        <param name="username" value="${GUAC_USERNAME}" />
        <param name="password" value="${GUAC_PASSWORD}" />
        <param name="security" value="any" />
        <param name="server-layout" value="en-us-qwerty" />
        <param name="ignore-cert" value="true" />
        <param name="disable-auth" value="true" />
    </config>

    <group name="users">
        <config-ref name="RDP Connection" />
    </group>
</unix-user-mapping>
```

If a user cannot login ensure they are part of the `users` group:

```bash
sudo usermod -a -G users $(whoami)
```

I also modified the home directory of the `daemon` user from `/` to `/tmp` because
`systemctl status guacd` was showing an error writing temporary files to $HOME.

You can do this by very carefully modifying the `daemon` account in `/etc/passwd`.

I also ran `xfreerdp` as `daemon` once to trust the certificate always:

```bash
sudo -u daemon xfreerdp /v:127.0.0.1
```

## DHCP Server

We are going to reconfigure the wifi card on the server to be a WiFi access point
suitable for student laptops/tablets/phones to connect to for access to their
offline learning environment. To make the offline environment online simply connect
the server to an internet connection, but note that this may be prohibited by
your organization. Always check before connecting a server to your organization's network.

| Hardware/Config item | Value |
|----------|--------------:|
| NIC name | `wlp0s29u1u5` |
| SSID     | `ManagedClass` |
| Wifi Password | `classPW01` |


```bash
yay -S hostapd create_ap
sudo systemctl diable hostapd
sudo systemctl stop hostapd
sudo create_ap wlp0s29u1u5 enp9s0 ManagedClass classPW01
```

Because `create_ap` must be run before the AP is available we will create a service for it:

```bash
vim /etc/systemd/system/managed-class-ap.service
```

which should contain

```
[Unit]
Description=ManagedClass wireless access point

[Service]
User=root
Type=simple
ExecStartPre=/sbin/nmcli r wifi off
ExecStartPre=/sbin/rfkill unblock wlan
ExecStart=/sbin/create_ap wlp0s29u1u5 enp9s0 ManagedClass classPW01
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

And enable it:

```bash
sudo systemctl enable --now managed-class-ap
```

## Graphical User Management

```bash
yay -S webmin
sudo systemctl enable --now webmin
# Webmin will listen on https://0.0.0.0:10000 and only
# the root user is allowed to login to manage the system.
```

## NginX Server

To provide documentation and links to all the
services we'll add an nginx server which listens to
`0.0.0.0:80` and write some `.html` to say hello to
our students.

```bash
yay -S nginx
sudo systemctl enable --now nginx
```





