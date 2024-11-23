#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
echo wintermute >/etc/hostname
sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\twintermute/g" /etc/hosts
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
echo "$FIRSTUSER:"'$5$.JCul6mnDH$/TjzLsqN9iHpAhva/OlrCoANkWNU7nn6dfQplh3.WBC' | chpasswd -e
systemctl enable ssh
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="mynetwork"
	psk=69e49214ef4e7e23d0ece077c2faf3c73f7522ad52a26b33527fa78d9033ff35
}

WPAEOF
chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
rfkill unblock wifi
for filename in /var/lib/systemd/rfkill/*:wlan ; do
  echo 0 > $filename
done
rm -f /etc/xdg/autostart/piwiz.desktop
rm -f /etc/localtime
echo "America/Los_Angeles" >/etc/timezone
dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
KBEOF
dpkg-reconfigure -f noninteractive keyboard-configuration
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
