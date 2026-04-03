#!/bin/bash
clear
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

# Script designed to upgrade dependencies in PNETLab UBUNTU 20.04
# Requirement: You need to have UBUNTU 20.04
# CONSTANTS
GREEN='\033[32m'
RED='\033[31m'
NO_COLOR='\033[0m'

KERNEL=pnetlab_kernel.zip
rm /var/lib/dpkg/lock* &>/dev/null
dpkg --configure -a &>/dev/null

URL_KERNEL="https://drive.labhub.eu.org/download.aspx?file=Zn0pw99cVBNp3wd29fYZ0LadlqAYNMmi8ufYkAjwyhQKFGaw8Wg1awicXfeQC6rP&expiry=oZ6nAJP3ZRj9dVTW%2F73ggw%3D%3D&mac=b70d3bb9d2f2c65ecfe94e7e96b86e3cf792ec43cc12af4867c7987e03303121"
URL_PRE_DOCKER="https://drive.labhub.eu.org/download.aspx?file=bs5dSKIGaAbsq0wYJTsZdFPLBaZic0cbRlYKIbZMflRqAgtpDLWeI0DUNYeZS6yP&expiry=FfKl290TgYar549DlvYP8g%3D%3D&mac=a30348a8c338b08b0321f8c398fa45dd0414b28bf03d73e14a025c60bea36d96"
URL_PNET_GUACAMOLE="https://drive.labhub.eu.org/download.aspx?file=9kP4lOqVbAL2e7RCD4gACmT3Ty10ApwC6CbYaTSfSGNHTnPiXzC4evQUn1G626Vr&expiry=UocZTSQ1fQ38qSPQmKa7dQ%3D%3D&mac=c41207880865e20787a0eed1b172d366045dfd832b5dedc4223f12a22875d5a9"
URL_PNET_DYNAMIPS="https://drive.labhub.eu.org/download.aspx?file=BsTBpIhpzPaYBQVL%2FH%2FxqmVxyGEIqECku%2BzPWlJAbvQR4SUMqvGgb1I96WUHE57t&expiry=%2F5DbEQ9LMUmMCl9iIiJxIA%3D%3D&mac=c36ad031d3a1f4579d04332b464323b618b9b9781a3855a947028dd33810d5f9"
URL_PNET_SCHEMA="https://drive.labhub.eu.org/download.aspx?file=5b5%2Bkss6OEnytNTrvW0%2BSfys3kvAw5kZ9knIsByE8Xo2qWdb%2FqIUD73GjZdKRGMi&expiry=XmOhwjDqeTSX0kRW4fBOhw%3D%3D&mac=1c8dc47be2e1453e5a6d7b7c23768b5721a33450ae6f5ca713780abd3dd6a942"
URL_PNET_VPC="https://drive.labhub.eu.org/download.aspx?file=6p0i2nwP%2BBiQBW33C9Bdh78eqhDWrtcmyaLu%2BoJwTKrIll%2FudVPnqr5T2UePd0d0&expiry=Tsf7FUe2nDOy5NOUAsm4AA%3D%3D&mac=2244f948d505c46d504de4cd6aabb12c548b02c47b46384ce52894cfb433cb54"
URL_PNET_QEMU="https://drive.labhub.eu.org/download.aspx?file=E7rs%2FIYUKkaBxI5C9P%2BTwnoUzdRovROxsjC97oyVUsFRjqfXAfKysNUZBqq1iAG9&expiry=feDP8uULPZ3RStZFUzPcQQ%3D%3D&mac=3db872648ef12f4f646e984082b8e4abdc7588e3bd52771c88d7e04cff457710"
URL_PNET_DOCKER="https://drive.labhub.eu.org/download.aspx?file=SMb4Rc%2BVL4PJX0Ky8jx2IUJufcT2CqKeEI8e2a4vTn7GIsH5AZPb4vKboDdEZick&expiry=EylbGs6RCo0nbExygbuP8Q%3D%3D&mac=be178618dde6a08bc5835ef367f96f56d95063f6410fd6acc4c8a15b6572b457"
URL_PNET_PNETLAB="https://drive.labhub.eu.org/download.aspx?file=P90Nk9tO%2BjYRvWt8u%2BNlmehbs6qncnO8Pqrx%2BJ63lAkdgn9zlJ93cNptI5KkUSDO&expiry=b81GIDSvoio0PFYh6XzGmw%3D%3D&mac=fa2b210f96c6498640718706645dd55d88cb98bb6114367c3ede272758aa3de0"
URL_PNET_WIRESHARK="https://drive.labhub.eu.org/download.aspx?file=YwTuRyx6cNhSY7X37edvA20LEuSYgatZU6zJ%2FEF88lTUxHuvKRACmhO19tReanbi&expiry=mOQxbBHxGtF0CCMFCg509w%3D%3D&mac=59e4ad197e34e093bb5170dc067053a385ef788bf6fe6c4c0d511667a6fe22a0"
URL_PNET_TPM="https://drive.labhub.eu.org/download.aspx?file=OijW0UJhUspy9vXDFXXDD1MWHCez6Y2a%2BCX7aiZMeuWnD1jKTPqU9kH5JMk1%2FRsQ&expiry=3c%2BTCYuIQA%2FAZyEibE2qsw%3D%3D&mac=5996818b3291175431a86a1146eb73d4220a277f08c258c06dffff4aa6703b99"

lsb_release -r -s | grep -q 20.04
if [ $? -ne 0 ]; then
    echo -e "${RED}Upgrade has been rejected. You need to have UBUNTU 20.04 to use this script${NO_COLOR}"
    exit 0
fi

# On Azure attach data disk
azure_disk_tune() {
    ls -l /dev/disk/by-id/ | grep -q sdc && (
        echo o # Create a new empty DOS partition table
        echo n # Add a new partition
        echo p # Primary partition
        echo 1 # Partition number
        echo   # First sector (Accept default: 1)
        echo   # Last sector (Accept default: varies)
        echo w # Write changes
    ) | sudo fdisk /dev/sdc && (
        mke2fs -F /dev/sdc1
        echo "/dev/sdc1	/opt	ext4	defaults,discard	0 0 " >>/etc/fstab
        mount /opt
    )
}

uname -a | grep -q -- "-azure " && azure_disk_tune

apt-get update
#permit root access from ssh
sed -i -e "s/.*PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config &>/dev/null
sed -i -e 's/.*DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=5s/' /etc/systemd/system.conf &>/dev/null
systemctl restart ssh &>/dev/null
#install  packages required
add-apt-repository --yes ppa:ondrej/php &>/dev/null
# set passwrod for root
if [ ! -e /opt/ovf/.configured ]; then
    echo root:pnet | chpasswd &>/dev/null
fi

# detect if pnet run will run under  bare metal or kvm hypervisor
systemd-detect-virt -v >/tmp/hypervisor
resize() {
    ROOTLV=$(mount | grep ' / ' | awk '{print $1}')
    echo "$ROOTLV"
    lvextend -l +100%FREE "$ROOTLV"
    echo Resizing ROOT FS
    resize2fs "$ROOTLV"
}
fgrep -e kvm -e none /tmp/hypervisor 2>&1 >/dev/null
if [[ $? -eq 0 ]]; then
    grep -q kvm /tmp/hypervisor && resize &>/dev/null
    grep -q none /tmp/hypervisor && resize &>/dev/null
fi

apt-get purge -y docker.io containerd runc php8* -q &>/dev/null

rm /var/lib/dpkg/lock* &>/dev/null
apt-get install -y ifupdown unzip &>/dev/null
echo -e "${GREEN}Downloading dependencies for PNETLAB ${NO_COLOR}"

sudo apt install -y resolvconf php7.4 php7.4-yaml php7.4-common php7.4-cli php7.4-curl php7.4-gd php7.4-mbstring php7.4-mysql php7.4-sqlite3 php7.4-xml php7.4-zip libapache2-mod-php7.4 libnet-pcap-perl duc libspice-client-glib-2.0-8 libtinfo5 libncurses5 libncursesw5 php-gd ntpdate vim dos2unix apache2 bridge-utils build-essential cpulimit debconf-utils dialog dmidecode genisoimage iptables lib32gcc1 lib32z1 pastebinit php-xml libc6 libc6-i386 libelf1 libpcap0.8 libsdl1.2debian logrotate lsb-release lvm2 ntp php rsync sshpass autossh php-cli php-imagick php-mysql php-sqlite3 plymouth-label python3-pexpect sqlite3 tcpdump telnet uml-utilities zip libguestfs-tools cgroup-tools libyaml-0-2 php-curl php-mbstring net-tools php-zip python2 libapache2-mod-php mysql-server libavcodec58 libavformat58 libavutil56 libswscale5 libfreerdp-client2-2 libfreerdp-server2-2 libfreerdp-shadow-subsystem2-2 libfreerdp-shadow2-2 libfreerdp2-2 winpr-utils gir1.2-pango-1.0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpangoxft-1.0-0 pango1.0-tools pkg-config libssh2-1 libtelnet2 libvncclient1 libvncserver1 libwebsockets15 libpulse0 libpulse-mainloop-glib0 libssl1.1 libvorbis0a libvorbisenc2 libvorbisfile3 libwebp6 libwebpmux3 libwebpdemux2 libcairo2 libcairo-gobject2 libcairo-script-interpreter2 libjpeg62 libpng16-16 libtool libuuid1 libossp-uuid16 default-jdk default-jdk-headless tomcat9 tomcat9-admin tomcat9-docs libaio1 libasound2 libbrlapi0.7 libcacard0 libepoxy0 libfdt1 libgbm1 libgcc-s1 libglib2.0-0 libgnutls30 libibverbs1 libjpeg8 libncursesw6 libnettle7 libnuma1 libpixman-1-0 libpmem1 librdmacm1 libsasl2-2 libseccomp2 libslirp0 libspice-server1 libtinfo6 libusb-1.0-0 libusbredirparser1 libvirglrenderer1 zlib1g qemu-system-common libxenmisc4.11 libcapstone3 libvdeplug2 libnfs13 udhcpd libxss1  libxencall1 libxendevicemodel1 libxenevtchn1 libxenforeignmemory1 libxengnttab1 libxenstore3.0 libxentoollog1 udhcpd libxss1 libxentoolcore1 libxentoollog1 libxencall1 libxendevicemodel1 libxenevtchn1 libxenmisc4.11 libcapstone3 libvdeplug2 libnfs13 php7.4 php7.4-cli php-common php7.4-curl php7.4-gd php7.4-mbstring php7.4-mysql php7.4-sqlite3 php7.4-xml php7.4-zip libapache2-mod-php7.4

update-alternatives --set php /usr/bin/php &>/dev/null

echo -e "${GREEN}Downloading PNETLAB PACKAGES ...${NO_COLOR}"
rm -rf /tmp/* &>/dev/null
cd /tmp 2>&1 >/dev/null

echo -e "${GREEN}$DOwnload Packages${NO_COLOR}"
dpkg-query -l | grep linux-image-5.17.15-pnetlab-uksm-2 | grep 5.17.15-pnetlab-uksm-2-1 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_KERNEL -O $KERNEL
    unzip /tmp/$KERNEL &>/dev/null
    dpkg -i /tmp/pnetlab_kernel/*.deb
fi

dpkg-query -l | grep docker-ce -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PRE_DOCKER -O pre-docker.zip
    unzip /tmp/pre-docker.zip &>/dev/null
    dpkg -i /tmp/pre-docker/*.deb
fi

dpkg-query -l | grep swtpm -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_TPM -O swtpm-focal.zip
    unzip /tmp/swtpm-focal.zip &>/dev/null
    dpkg -i /tmp/swtpm-focal/*.deb
fi

dpkg-query -l | grep pnetlab-docker | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_DOCKER -O pnetlab-docker_6.0.0-30_amd64.deb
    dpkg -i /tmp/pnetlab-docker_*.deb
fi

dpkg-query -l | grep pnetlab-schema | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_SCHEMA -O pnetlab-schema_6.0.0-30_amd64.deb
    dpkg -i /tmp/pnetlab-schema_*.deb
fi

dpkg-query -l | grep pnetlab-guacamole | grep 6.0.0-7 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_GUACAMOLE -O pnetlab-guacamole_6.0.0-7_amd64.deb
    dpkg -i /tmp/pnetlab-guacamole_*.deb
fi

dpkg-query -l | grep pnetlab-vpcs | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_VPC -O pnetlab-vpcs_6.0.0-30_amd64.deb
    dpkg -i /tmp/pnetlab-vpcs_*.deb
fi

dpkg-query -l | grep pnetlab-dynamips | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_DYNAMIPS -O pnetlab-dynamips_6.0.0-30_amd64.deb
    dpkg -i /tmp/pnetlab-dynamips_*.deb
fi

dpkg-query -l | grep pnetlab-wireshark | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_WIRESHARK -O pnetlab-wireshark_6.0.0-30_amd64.deb
    dpkg -i pnetlab-wireshark_6.0.0-30_amd64.deb
fi

dpkg-query -l | grep pnetlab-qemu | grep 6.0.0-30 -q
if [ $? -ne 0 ]; then
    wget --content-disposition -q --show-progress $URL_PNET_QEMU -O pnetlab-qemu_6.0.0-30_amd64.deb
    dpkg -i /tmp/pnetlab-qemu_*.deb
fi
fgrep "127.0.1.1 pnetlab.example.com pnetlab" /etc/hosts || echo 127.0.2.1 pnetlab.example.com pnetlab >>/etc/hosts 2>/dev/null
echo pnetlab >/etc/hostname 2>/dev/null

echo -e "${GREEN}installing pnetlab...${NO_COLOR}"
wget --content-disposition -q --show-progress $URL_PNET_PNETLAB -O pnetlab_6.0.0-103_amd64.deb
dpkg -i /tmp/pnetlab_6*.deb

# Detect cloud

gcp_tune() {
    cd /sys/class/net/
    for i in ens*; do echo 'SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="'$(cat $i/address)'", ATTR{type}=="1", KERNEL=="ens*", NAME="'$i'"'; done >/etc/udev/rules.d/70-persistent-net.rules
    sed -i -e 's/NAME="ens.*/NAME="eth0"/' /etc/udev/rules.d/70-persistent-net.rules
    sed -i -e 's/ens4/eth0/' /etc/netplan/50-cloud-init.yaml
    sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    apt-mark hold linux-image-gcp
    mv /boot/vmlinuz-*gcp /root
    update-grub2
}

azure_kernel_tune() {
    apt update
    echo "options kvm_intel nested=1 vmentry_l1d_flush=never" >/etc/modprobe.d/qemu-system-x86.conf
    sed -i -e 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo -i
}

# GCP
dmidecode -t bios | grep -q Google && gcp_tune

# Azure

uname -a | grep -q -- "-azure " && azure_kernel_tune

apt autoremove -y -q
apt autoclean -y -q
echo -e "${GREEN}Upgrade has been done successfully ${NO_COLOR}"
echo -e "${GREEN}Default credentials: username=root password=pnet Make sure reboot if you install pnetlab first time ${NO_COLOR}"
