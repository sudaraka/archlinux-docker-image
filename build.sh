#!/usr/bin/sh
#
# build.sh: Install Arch Linux packages into a temporary location and build a
#           Docker image from it
#
# Copyright 2015, Sudaraka Wijesinghe <sudaraka@sudaraka.org>
#
# This program comes with ABSOLUTELY NO WARRANTY;
# This is free software, and you are welcome to redistribute it and/or modify it
# under the terms of the BSD 2-clause License. See the LICENSE file for more
# details.
#

source ./utils.sh
source ./fs.sh
source ./pacman.sh

madb_print_copyright

if [ `id -u` -ne 0 ]; then
    echo 'Please run as root.'
    echo

    exit 1
fi

if [ ! -x "`which expect 2>/dev/null`" ]; then
    echo 'Please install "expect" and try again'
    echo

    exit 1
fi

IMAGE_NAME=$1
shift

if [ -z "$IMAGE_NAME" ]; then
    madb_print_usage
    exit 1
fi

FS_ROOT="${TMPDIR:-/tmp}/$IMAGE_NAME-root"

madb_fs_init $FS_ROOT

madb_install_packages $FS_ROOT

# Initialize pacman keys
madb_mount proc "$FS_ROOT/proc" -t proc -o nosuid,noexec,nodev
chroot $FS_ROOT /bin/sh -c 'haveged -w 1024; pacman-key --init; pkill haveged; pacman -Rcnsu --noconfirm haveged; pacman-key --populate archlinux; pkill gpg-agent'

# Set default timezone to Asia/Colombo
ln -s /usr/share/zoneinfo/Asia/Colombo $FS_ROOT/etc/localtime

# Generate locale and set default to en_US (UTF-8)
cat<<EOF >> $FS_ROOT/etc/locale.gen
en_US UTF-8
EOF

cat<<EOF > $FS_ROOT/etc/locale.conf
LANG=en_US
EOF

chroot $FS_ROOT /bin/sh -c 'locale-gen'

# Create pacman mirror list
wget 'https://www.archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on' -qO -| \
    sed 's/^#\(.\+\)/\1/g' \
    > $FS_ROOT/etc/pacman.d/mirrorlist

madb_umount

IMAGE_SIZE=`du -sh $FS_ROOT|awk '{print $1}'`

echo
echo "Generated filesystem ($IMAGE_SIZE)"
echo

# make sure Docker is running
systemctl start docker

tar --numeric-owner --xattrs --acls -C $FS_ROOT -c . | docker import - $IMAGE_NAME
